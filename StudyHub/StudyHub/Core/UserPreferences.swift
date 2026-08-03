import Foundation
import SwiftUI

/// Follows the system appearance unless explicitly overridden — mirrors
/// what `.preferredColorScheme(nil)` already means, just as an explicit,
/// user-facing choice in Settings.
enum AppearancePreference: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    /// `nil` tells SwiftUI "don't override — follow the system," matching
    /// `.preferredColorScheme`'s own `ColorScheme?` parameter type exactly.
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

/// App-wide display preferences the user can change in Settings — deliberately
/// separate from `AppState` (runtime state derived from the model graph,
/// like the active Semester) since these are plain UI preferences with no
/// SwiftData backing at all, persisted via `UserDefaults`.
@MainActor
@Observable
final class UserPreferences {
    private static let weekStartsOnMondayKey = "weekStartsOnMonday"
    private static let appearanceKey = "appearancePreference"
    private static let userNameKey = "userName"
    private static let defaultLectureDurationMinutesKey = "defaultLectureDurationMinutes"
    private static let notificationsEnabledKey = "notificationsEnabled"
    private static let dueSoonReminderLeadHoursKey = "dueSoonReminderLeadHours"
    private static let dailyDigestEnabledKey = "dailyDigestEnabled"
    private static let dailyDigestHourKey = "dailyDigestHour"
    private static let examReflectionNudgeEnabledKey = "examReflectionNudgeEnabled"
    private static let remindersSyncEnabledKey = "remindersSyncEnabled"
    private static let calendarPushEnabledKey = "calendarPushEnabled"
    private static let lectureSourceCalendarIdentifierKey = "lectureSourceCalendarIdentifier"

    private let defaults: UserDefaults

    /// Defaults to Monday — matches how most calendar apps outside the US
    /// lay out a week, and this project's own stated preference. Anyone who
    /// wants Sunday-first can switch it in Settings.
    var weekStartsOnMonday: Bool {
        didSet {
            defaults.set(weekStartsOnMonday, forKey: Self.weekStartsOnMondayKey)
        }
    }

    var appearance: AppearancePreference {
        didSet {
            defaults.set(appearance.rawValue, forKey: Self.appearanceKey)
        }
    }

    /// Shown in Home's greeting ("Good morning, Kartik") — empty means no
    /// name has been set yet, in which case the greeting just omits it.
    var userName: String {
        didSet {
            defaults.set(userName, forKey: Self.userNameKey)
        }
    }

    /// How long a new Lecture's End Time defaults to after Start Time —
    /// used only when creating a Lecture (see `LectureFormView`). Defaults
    /// to 60, a plain hour-long class being the most common case.
    var defaultLectureDurationMinutes: Int {
        didSet {
            defaults.set(defaultLectureDurationMinutes, forKey: Self.defaultLectureDurationMinutesKey)
        }
    }

    /// Master switch for every local notification (due-soon reminders,
    /// daily digest, exam reflection nudge). Off by default — turning it on
    /// in Settings is what triggers the system permission prompt.
    var notificationsEnabled: Bool {
        didSet {
            defaults.set(notificationsEnabled, forKey: Self.notificationsEnabledKey)
        }
    }

    /// How long before an Assignment/Exam/Reading is due its "due soon"
    /// notification fires — one shared lead time for all three rather than
    /// a separate setting per type, to keep this configurable without
    /// turning into its own maze of options.
    var dueSoonReminderLeadHours: Int {
        didSet {
            defaults.set(dueSoonReminderLeadHours, forKey: Self.dueSoonReminderLeadHoursKey)
        }
    }

    var dailyDigestEnabled: Bool {
        didSet {
            defaults.set(dailyDigestEnabled, forKey: Self.dailyDigestEnabledKey)
        }
    }

    /// 24-hour clock hour the daily flashcard/active-recall digest fires at.
    var dailyDigestHour: Int {
        didSet {
            defaults.set(dailyDigestHour, forKey: Self.dailyDigestHourKey)
        }
    }

    var examReflectionNudgeEnabled: Bool {
        didSet {
            defaults.set(examReflectionNudgeEnabled, forKey: Self.examReflectionNudgeEnabledKey)
        }
    }

    /// Push Assignments to a dedicated "StudyHub" Reminders list, with
    /// completion synced back on load — separate from `notificationsEnabled`
    /// since this is EventKit access, not `UserNotifications`.
    var remindersSyncEnabled: Bool {
        didSet {
            defaults.set(remindersSyncEnabled, forKey: Self.remindersSyncEnabledKey)
        }
    }

    /// Push Assignments + Exams into a dedicated "StudyHub Deadlines"
    /// Apple Calendar. Independent of a course's `linkedCalendarIdentifier`
    /// (lecture import), which always runs once a course has one set.
    var calendarPushEnabled: Bool {
        didSet {
            defaults.set(calendarPushEnabled, forKey: Self.calendarPushEnabledKey)
        }
    }

    /// `EKCalendar.calendarIdentifier` of a single existing Apple Calendar
    /// every course's Lectures import from — one global setting rather than
    /// a per-course pick, since most students have one timetable calendar
    /// covering every class. Syncing matches each event to a course by
    /// checking whether the event's title contains that course's name or
    /// code (see `SettingsViewModel.syncAllLectures`).
    var lectureSourceCalendarIdentifier: String? {
        didSet {
            defaults.set(lectureSourceCalendarIdentifier, forKey: Self.lectureSourceCalendarIdentifierKey)
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if defaults.object(forKey: Self.weekStartsOnMondayKey) == nil {
            weekStartsOnMonday = true
        } else {
            weekStartsOnMonday = defaults.bool(forKey: Self.weekStartsOnMondayKey)
        }

        if let rawValue = defaults.string(forKey: Self.appearanceKey), let stored = AppearancePreference(rawValue: rawValue) {
            appearance = stored
        } else {
            appearance = .system
        }

        userName = defaults.string(forKey: Self.userNameKey) ?? ""

        if defaults.object(forKey: Self.defaultLectureDurationMinutesKey) == nil {
            defaultLectureDurationMinutes = 60
        } else {
            defaultLectureDurationMinutes = defaults.integer(forKey: Self.defaultLectureDurationMinutesKey)
        }

        notificationsEnabled = defaults.bool(forKey: Self.notificationsEnabledKey)

        if defaults.object(forKey: Self.dueSoonReminderLeadHoursKey) == nil {
            dueSoonReminderLeadHours = 24
        } else {
            dueSoonReminderLeadHours = defaults.integer(forKey: Self.dueSoonReminderLeadHoursKey)
        }

        dailyDigestEnabled = defaults.bool(forKey: Self.dailyDigestEnabledKey)

        if defaults.object(forKey: Self.dailyDigestHourKey) == nil {
            dailyDigestHour = 9
        } else {
            dailyDigestHour = defaults.integer(forKey: Self.dailyDigestHourKey)
        }

        if defaults.object(forKey: Self.examReflectionNudgeEnabledKey) == nil {
            examReflectionNudgeEnabled = true
        } else {
            examReflectionNudgeEnabled = defaults.bool(forKey: Self.examReflectionNudgeEnabledKey)
        }

        remindersSyncEnabled = defaults.bool(forKey: Self.remindersSyncEnabledKey)
        calendarPushEnabled = defaults.bool(forKey: Self.calendarPushEnabledKey)
        lectureSourceCalendarIdentifier = defaults.string(forKey: Self.lectureSourceCalendarIdentifierKey)
    }

    /// A `Calendar` configured to agree with this preference — pass this
    /// (not `Calendar.current`) anywhere "start of week"/"which day is
    /// first" matters, so every screen stays consistent with the same
    /// setting. `firstWeekday`: 1 = Sunday, 2 = Monday (`Calendar`'s own
    /// numbering, matching `component(.weekday:)`).
    var calendar: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = weekStartsOnMonday ? 2 : 1
        return calendar
    }
}
