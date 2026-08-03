import EventKit
import Foundation

/// A calendar the user could link a course's Lectures to — deliberately not
/// `EKCalendar` itself, so nothing above this layer needs to import
/// EventKit.
struct ExternalCalendarInfo: Identifiable, Hashable {
    let id: String
    let title: String
}

/// One imported occurrence from a linked external calendar — a flattened,
/// EventKit-free read of an `EKEvent` (recurring events expand to one of
/// these per occurrence within the queried date window, which lines up
/// naturally with `Lecture` already being "one row per date", no recurrence
/// concept needed on our side).
struct ExternalCalendarEvent {
    let identifier: String
    let title: String
    let startDate: Date
    let endDate: Date
    let location: String
}

/// EventKit wrapper — the only file in the app that imports EventKit.
/// Handles both Calendar (`EKEvent`) and Reminders (`EKReminder`), since
/// they share the same permission model and store. Two independent uses:
/// pushing Assignments/Exams out as events/reminders into a dedicated
/// "StudyHub" calendar/list this app owns, and importing a *different*,
/// user-picked, pre-existing calendar's events into Lectures (read-only on
/// our side — the external calendar stays the source of truth for those).
protocol CalendarSyncServiceProtocol {
    func requestEventAccess() async -> Bool
    func requestReminderAccess() async -> Bool
    func hasEventAccess() -> Bool
    func hasReminderAccess() -> Bool

    /// Every calendar that supports events, for the "which calendar are
    /// your lectures on" picker — excludes the dedicated StudyHub calendar
    /// itself, since that one is StudyHub's own output, not an import
    /// source.
    func availableEventCalendars() -> [ExternalCalendarInfo]
    func fetchEvents(calendarIdentifier: String, from: Date, to: Date) -> [ExternalCalendarEvent]

    /// Creates (when `existingIdentifier` is `nil`) or updates an event in
    /// the app's own dedicated calendar. Returns the event's identifier, or
    /// `nil` if the save failed (e.g. access was revoked after the initial
    /// grant).
    @discardableResult
    func upsertStudyHubEvent(existingIdentifier: String?, title: String, startDate: Date, endDate: Date, location: String) -> String?
    func deleteEvent(identifier: String)

    @discardableResult
    func upsertStudyHubReminder(existingIdentifier: String?, title: String, dueDate: Date, isCompleted: Bool) -> String?
    /// `nil` if the reminder no longer exists (deleted on the Reminders
    /// side) rather than `false`, so a caller can tell "not completed" apart
    /// from "nothing to reconcile."
    func reminderCompletion(identifier: String) -> Bool?
    func deleteReminder(identifier: String)
}

final class CalendarSyncService: CalendarSyncServiceProtocol {
    private let store = EKEventStore()
    private static let eventCalendarTitle = "StudyHub Deadlines"
    private static let reminderListTitle = "StudyHub"

    func requestEventAccess() async -> Bool {
        (try? await store.requestFullAccessToEvents()) ?? false
    }

    func requestReminderAccess() async -> Bool {
        (try? await store.requestFullAccessToReminders()) ?? false
    }

    func hasEventAccess() -> Bool {
        EKEventStore.authorizationStatus(for: .event) == .fullAccess
    }

    func hasReminderAccess() -> Bool {
        EKEventStore.authorizationStatus(for: .reminder) == .fullAccess
    }

    func availableEventCalendars() -> [ExternalCalendarInfo] {
        guard hasEventAccess() else { return [] }
        return store.calendars(for: .event)
            .filter { $0.title != Self.eventCalendarTitle }
            .map { ExternalCalendarInfo(id: $0.calendarIdentifier, title: $0.title) }
            .sorted { $0.title < $1.title }
    }

    func fetchEvents(calendarIdentifier: String, from: Date, to: Date) -> [ExternalCalendarEvent] {
        guard hasEventAccess(), let calendar = store.calendar(withIdentifier: calendarIdentifier) else { return [] }
        let predicate = store.predicateForEvents(withStart: from, end: to, calendars: [calendar])
        return store.events(matching: predicate).map {
            ExternalCalendarEvent(
                identifier: $0.eventIdentifier,
                title: $0.title ?? "",
                startDate: $0.startDate,
                endDate: $0.endDate,
                location: $0.location ?? ""
            )
        }
    }

    @discardableResult
    func upsertStudyHubEvent(existingIdentifier: String?, title: String, startDate: Date, endDate: Date, location: String) -> String? {
        guard hasEventAccess() else { return nil }
        let event: EKEvent
        if let existingIdentifier, let found = store.event(withIdentifier: existingIdentifier) {
            event = found
        } else {
            event = EKEvent(eventStore: store)
            event.calendar = studyHubCalendar()
        }
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.location = location

        do {
            try store.save(event, span: .thisEvent)
            return event.eventIdentifier
        } catch {
            return nil
        }
    }

    func deleteEvent(identifier: String) {
        guard let event = store.event(withIdentifier: identifier) else { return }
        try? store.remove(event, span: .thisEvent)
    }

    @discardableResult
    func upsertStudyHubReminder(existingIdentifier: String?, title: String, dueDate: Date, isCompleted: Bool) -> String? {
        guard hasReminderAccess() else { return nil }
        let reminder: EKReminder
        if let existingIdentifier, let found = store.calendarItem(withIdentifier: existingIdentifier) as? EKReminder {
            reminder = found
        } else {
            reminder = EKReminder(eventStore: store)
            reminder.calendar = studyHubReminderList()
        }
        reminder.title = title
        reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        reminder.isCompleted = isCompleted

        do {
            try store.save(reminder, commit: true)
            return reminder.calendarItemIdentifier
        } catch {
            return nil
        }
    }

    func reminderCompletion(identifier: String) -> Bool? {
        guard let reminder = store.calendarItem(withIdentifier: identifier) as? EKReminder else { return nil }
        return reminder.isCompleted
    }

    func deleteReminder(identifier: String) {
        guard let reminder = store.calendarItem(withIdentifier: identifier) as? EKReminder else { return }
        try? store.remove(reminder, commit: true)
    }

    /// Finds StudyHub's own dedicated events calendar, creating it once
    /// (on the same source as the device's default calendar) if it doesn't
    /// exist yet.
    private func studyHubCalendar() -> EKCalendar {
        if let existing = store.calendars(for: .event).first(where: { $0.title == Self.eventCalendarTitle }) {
            return existing
        }
        let calendar = EKCalendar(for: .event, eventStore: store)
        calendar.title = Self.eventCalendarTitle
        calendar.source = store.defaultCalendarForNewEvents?.source ?? store.sources.first(where: { $0.sourceType == .local }) ?? store.sources.first
        try? store.saveCalendar(calendar, commit: true)
        return calendar
    }

    private func studyHubReminderList() -> EKCalendar {
        if let existing = store.calendars(for: .reminder).first(where: { $0.title == Self.reminderListTitle }) {
            return existing
        }
        let calendar = EKCalendar(for: .reminder, eventStore: store)
        calendar.title = Self.reminderListTitle
        calendar.source = store.defaultCalendarForNewReminders()?.source ?? store.sources.first(where: { $0.sourceType == .local }) ?? store.sources.first
        try? store.saveCalendar(calendar, commit: true)
        return calendar
    }
}
