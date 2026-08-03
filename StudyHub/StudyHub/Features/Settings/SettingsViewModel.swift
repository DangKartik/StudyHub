import Foundation

/// Backs the Settings page's global Lectures sync — one calendar shared
/// across every course (see `UserPreferences.lectureSourceCalendarIdentifier`),
/// unlike the old per-course link. Since one calendar can hold events for
/// many different classes, each event is matched to whichever active course's
/// name or course code appears in its title; an event that matches nothing
/// is simply skipped rather than creating an unowned Lecture no course page
/// would ever show.
@MainActor
@Observable
final class SettingsViewModel {
    private let appState: AppState
    private let courseRepository: any CourseRepositoryProtocol
    private let lectureRepository: any LectureRepositoryProtocol
    private let calendarRepository: any CalendarRepositoryProtocol
    private let calendarSyncService: any CalendarSyncServiceProtocol
    private let userPreferences: UserPreferences

    private(set) var isSyncingLectures = false
    private(set) var lastSyncSummary: String?

    init(
        appState: AppState,
        courseRepository: any CourseRepositoryProtocol,
        lectureRepository: any LectureRepositoryProtocol,
        calendarRepository: any CalendarRepositoryProtocol,
        calendarSyncService: any CalendarSyncServiceProtocol,
        userPreferences: UserPreferences
    ) {
        self.appState = appState
        self.courseRepository = courseRepository
        self.lectureRepository = lectureRepository
        self.calendarRepository = calendarRepository
        self.calendarSyncService = calendarSyncService
        self.userPreferences = userPreferences
    }

    /// One-directional mirror, same reasoning as the original per-course
    /// version: the linked calendar is always the source of truth. A
    /// Lecture whose source event disappears is unlinked, never deleted, so
    /// any notes/attachments added to it survive.
    func syncAllLectures() {
        guard let calendarIdentifier = userPreferences.lectureSourceCalendarIdentifier else { return }
        guard let semester = appState.activeSemester else {
            lastSyncSummary = "No active semester."
            return
        }

        isSyncingLectures = true
        defer { isSyncingLectures = false }

        let courses = ((try? courseRepository.fetch(forSemester: semester)) ?? []).filter { !$0.isArchived }
        guard !courses.isEmpty else {
            lastSyncSummary = "No active courses to sync into."
            return
        }

        let now = Date.now
        let windowStart = Calendar.current.date(byAdding: .weekOfYear, value: -2, to: now) ?? now
        let windowEnd = Calendar.current.date(byAdding: .weekOfYear, value: 16, to: now) ?? now
        let externalEvents = calendarSyncService.fetchEvents(calendarIdentifier: calendarIdentifier, from: windowStart, to: windowEnd)
        let externalIdentifiers = Set(externalEvents.map(\.identifier))

        var existingLecturesByCourse: [UUID: [Lecture]] = [:]
        for course in courses {
            existingLecturesByCourse[course.id] = (try? lectureRepository.fetch(forCourse: course)) ?? []
        }

        var matchedCount = 0
        var unmatchedCount = 0

        for event in externalEvents {
            guard let course = bestMatchingCourse(for: event.title, among: courses) else {
                unmatchedCount += 1
                continue
            }
            matchedCount += 1

            if let reference = try? calendarRepository.fetch(byEventIdentifier: event.identifier) {
                guard let lecture = existingLecturesByCourse[course.id]?.first(where: { $0.calendarEventReference?.id == reference.id }) else { continue }
                lecture.title = event.title
                lecture.date = event.startDate
                lecture.startTime = event.startDate
                lecture.endTime = event.endDate
                lecture.location = event.location
                lecture.updatedAt = .now
            } else {
                let lecture = Lecture(title: event.title, date: event.startDate, startTime: event.startDate, endTime: event.endDate, location: event.location)
                lecture.course = course
                try? lectureRepository.create(lecture)

                let reference = CalendarEventReference(eventIdentifier: event.identifier, calendarIdentifier: calendarIdentifier, lastSynced: .now, syncStatus: .synced)
                try? calendarRepository.create(reference)
                lecture.calendarEventReference = reference
                existingLecturesByCourse[course.id, default: []].append(lecture)
            }
        }

        for lectures in existingLecturesByCourse.values {
            for lecture in lectures {
                guard let reference = lecture.calendarEventReference,
                      reference.calendarIdentifier == calendarIdentifier,
                      !externalIdentifiers.contains(reference.eventIdentifier) else { continue }
                lecture.calendarEventReference = nil
                try? calendarRepository.delete(reference)
            }
        }

        try? lectureRepository.save()

        var summary = "\(matchedCount) lecture\(matchedCount == 1 ? "" : "s") synced"
        if unmatchedCount > 0 {
            summary += ", \(unmatchedCount) event\(unmatchedCount == 1 ? "" : "s") didn't match a course"
        }
        lastSyncSummary = summary
    }

    /// First active course whose name or course code appears in the
    /// event's title (case-insensitive) — e.g. an event titled "CS201
    /// Lecture" matches a course with code "CS201".
    private func bestMatchingCourse(for eventTitle: String, among courses: [Course]) -> Course? {
        let title = eventTitle.lowercased()
        return courses.first { course in
            let code = course.courseCode.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let name = course.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            return (!code.isEmpty && title.contains(code)) || (!name.isEmpty && title.contains(name))
        }
    }
}
