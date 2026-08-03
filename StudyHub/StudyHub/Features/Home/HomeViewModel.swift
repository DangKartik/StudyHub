import Foundation

@MainActor
@Observable
final class HomeViewModel {
    private let appState: AppState
    private let userPreferences: UserPreferences
    private let courseRepository: any CourseRepositoryProtocol
    private let assignmentRepository: any AssignmentRepositoryProtocol
    private let readingRepository: any ReadingRepositoryProtocol
    private let flashcardRepository: any FlashcardRepositoryProtocol
    private let activeRecallRepository: any ActiveRecallRepositoryProtocol
    private let studySessionRepository: any StudySessionRepositoryProtocol
    private let quoteRepository: any QuoteRepositoryProtocol
    private let notificationManager: any NotificationSchedulingProtocol

    private(set) var activeSemester: Semester?
    private(set) var courseCount: Int = 0
    private(set) var assignmentsDueToday: [Assignment] = []
    private(set) var upcomingAssignments: [Assignment] = []
    /// Exams (an existing, real per-course feature reached via each
    /// Course's "Grades" tab — not new scaffolding) landing within the
    /// next `nearExamWindowDays`, across every active course. Home only
    /// ever shows the near-term ones; browsing every exam still happens
    /// per-course via Grades.
    private(set) var upcomingExams: [Assessment] = []
    /// Readings with a due date today or later, across every active
    /// course — same "near-term, real data" shape as
    /// `upcomingAssignments`/`upcomingExams`. A reading with no due date
    /// set at all never appears here, same as an assignment/exam couldn't
    /// exist without one.
    private(set) var upcomingReadings: [Reading] = []
    /// Up to `recentCoursesLimit` active courses, most-recently-studied
    /// first (falling back to alphabetical for courses never studied yet)
    /// — replaces the old static "View Courses" button with an actual
    /// glanceable, tappable set of courses, same "surface real data instead
    /// of just a button" direction the rest of Home already took.
    private(set) var recentCourses: [Course] = []
    private(set) var loadError: StudyHubError?
    /// True only until the very first `loadDashboard()` call finishes —
    /// avoids a one-frame flash of "No Courses Yet"/"Nothing Due Today"
    /// empty states before the real (fast, local, synchronous) fetch
    /// actually populates them.
    private(set) var isLoading = true

    /// Study Overview card (added when Spaced Repetition — Phase 4.4 — was
    /// surfaced on Home): due counts across every course, not scoped to the
    /// active semester, since a due card doesn't stop being due just
    /// because its course belongs to a different semester.
    private(set) var dueFlashcardsCount: Int = 0
    private(set) var dueQuestionsCount: Int = 0
    /// Real study-time/streak numbers — shares `StudyTimeSummary.compute`
    /// with `AnalyticsViewModel` rather than re-deriving them, and replaces
    /// the old `StatisticsSnapshot`-backed read, which never had any real
    /// data (confirmed zero writers anywhere in the codebase — the "Study
    /// Statistics" section always showed its empty state).
    private(set) var studyTimeSummary = StudyTimeSummary()
    private(set) var quoteOfTheDay: String = ""
    private(set) var greeting: String = ""

    private static let nearExamWindowDays = 14
    private static let recentCoursesLimit = 4

    init(
        appState: AppState,
        userPreferences: UserPreferences,
        courseRepository: any CourseRepositoryProtocol,
        assignmentRepository: any AssignmentRepositoryProtocol,
        readingRepository: any ReadingRepositoryProtocol,
        flashcardRepository: any FlashcardRepositoryProtocol,
        activeRecallRepository: any ActiveRecallRepositoryProtocol,
        studySessionRepository: any StudySessionRepositoryProtocol,
        quoteRepository: any QuoteRepositoryProtocol,
        notificationManager: any NotificationSchedulingProtocol
    ) {
        self.appState = appState
        self.userPreferences = userPreferences
        self.courseRepository = courseRepository
        self.assignmentRepository = assignmentRepository
        self.readingRepository = readingRepository
        self.flashcardRepository = flashcardRepository
        self.activeRecallRepository = activeRecallRepository
        self.studySessionRepository = studySessionRepository
        self.quoteRepository = quoteRepository
        self.notificationManager = notificationManager
    }

    private static let dailyDigestNotificationID = "dailyFlashcardDigest"

    func loadDashboard() {
        defer { isLoading = false }
        refreshGreeting()
        loadStudyOverview()

        guard let semester = appState.activeSemester else {
            activeSemester = nil
            courseCount = 0
            assignmentsDueToday = []
            upcomingAssignments = []
            upcomingExams = []
            upcomingReadings = []
            recentCourses = []
            loadError = nil
            return
        }

        activeSemester = semester

        do {
            let activeCourses = try courseRepository.fetch(forSemester: semester).filter { !$0.isArchived }
            courseCount = activeCourses.count
            let courseIDs = Set(activeCourses.map(\.id))
            recentCourses = computeRecentCourses(from: activeCourses)

            var allAssignments: [Assignment] = []
            var allExams: [Assessment] = []
            var allReadings: [Reading] = []
            for course in activeCourses {
                allAssignments.append(contentsOf: try assignmentRepository.fetch(forCourse: course))
                allExams.append(contentsOf: try courseRepository.fetchAssessments(for: course).filter { $0.kind == .exam })
                allReadings.append(contentsOf: try readingRepository.fetch(forCourse: course))
            }

            let now = Date.now
            upcomingAssignments = Array(
                allAssignments
                    .filter { $0.status != .completed && $0.dueDate >= now }
                    .sorted { $0.dueDate < $1.dueDate }
                    .prefix(5)
            )

            let dueToday = try assignmentRepository.dueToday()
            assignmentsDueToday = dueToday.filter { assignment in
                guard let courseID = assignment.course?.id else { return false }
                return courseIDs.contains(courseID)
            }

            let examWindowEnd = userPreferences.calendar.date(byAdding: .day, value: Self.nearExamWindowDays, to: now) ?? now
            upcomingExams = allExams
                .filter { $0.date >= now && $0.date <= examWindowEnd }
                .sorted { $0.date < $1.date }

            upcomingReadings = Array(
                allReadings
                    // Calendar-day comparison via `dueStatus`, not a raw
                    // timestamp check — Reading's due date has no time
                    // picker, so a reading due "today" carries whatever
                    // exact instant the form happened to save at. A plain
                    // `dueDate >= now` would exclude it the moment the
                    // clock ticks past that instant, even though it's
                    // still due today.
                    .filter { $0.dueStatus != .notDue }
                    .sorted { lhs, rhs in
                        // Due Today outranks Due Soon everywhere a Reading
                        // is shown — same `Reading.DueStatus` tiering
                        // `ReadingViewModel`'s own list order uses.
                        if lhs.dueStatus != rhs.dueStatus {
                            return lhs.dueStatus < rhs.dueStatus
                        }
                        return (lhs.dueDate ?? .distantFuture) < (rhs.dueDate ?? .distantFuture)
                    }
                    .prefix(5)
            )

            loadError = nil
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.fetchFailed(underlying: error)
        }
    }

    /// Ranks active courses by their most recent Study Session (either
    /// directly on the course, or on one of its Lectures), most recent
    /// first; courses never studied yet sort alphabetically after every
    /// studied one, rather than being scattered arbitrarily among them.
    private func computeRecentCourses(from activeCourses: [Course]) -> [Course] {
        guard !activeCourses.isEmpty else { return [] }

        let sessions = (try? studySessionRepository.fetchAll()) ?? []
        var lastStudiedByCourseID: [UUID: Date] = [:]
        for session in sessions {
            guard let courseID = session.course?.id ?? session.lecture?.course?.id else { continue }
            if let existing = lastStudiedByCourseID[courseID], existing >= session.startTime { continue }
            lastStudiedByCourseID[courseID] = session.startTime
        }

        let sorted = activeCourses.sorted { a, b in
            switch (lastStudiedByCourseID[a.id], lastStudiedByCourseID[b.id]) {
            case let (dateA?, dateB?): return dateA > dateB
            case (.some, nil): return true
            case (nil, .some): return false
            case (nil, nil): return a.name < b.name
            }
        }
        return Array(sorted.prefix(Self.recentCoursesLimit))
    }

    /// Picks a fresh greeting phrase (see `GreetingLibrary`) every time Home
    /// loads, matching the same hour window it's actually called in, and
    /// appends the user's name from Settings if one's been set.
    private func refreshGreeting() {
        let hour = Calendar.current.component(.hour, from: .now)
        let phrase = GreetingLibrary.randomPhrase(hour: hour)
        let name = userPreferences.userName.trimmingCharacters(in: .whitespacesAndNewlines)
        greeting = name.isEmpty ? phrase : "\(phrase), \(name)"
    }

    /// Due counts, study-time summary, and quote — deliberately independent
    /// of `appState.activeSemester` (unlike the rest of `loadDashboard()`),
    /// since none of these depend on which semester a course belongs to.
    /// Falls back to defaults on failure rather than surfacing `loadError`
    /// — these are supplementary stats, not core dashboard data.
    private func loadStudyOverview() {
        dueFlashcardsCount = (try? flashcardRepository.fetchAll())?
            .filter { DueQueueSection.classify(nextReviewDate: $0.nextReviewDate).isDueNow }
            .count ?? 0

        dueQuestionsCount = (try? activeRecallRepository.fetchAll())?
            .filter { DueQueueSection.classify(nextReviewDate: $0.nextReviewDate).isDueNow }
            .count ?? 0

        let sessions = (try? studySessionRepository.fetchAll()) ?? []
        studyTimeSummary = StudyTimeSummary.compute(sessions: sessions, calendar: userPreferences.calendar)

        // `QuoteRepository.nextQuote()` cycles through every quote exactly
        // once (marking it shown) before repeating any — each visit to Home
        // advances the rotation by one, rather than showing a fixed "quote
        // of the day" that only changes at midnight.
        if let quote = try? quoteRepository.nextQuote() {
            quoteOfTheDay = quote.text
        }

        refreshDailyDigestNotification()
    }

    /// Re-adding a daily-repeating request under the same identifier
    /// atomically replaces the previous one — so calling this on every
    /// Home load keeps the digest's body text current with the live due
    /// count without ever creating a duplicate notification.
    private func refreshDailyDigestNotification() {
        guard userPreferences.notificationsEnabled, userPreferences.dailyDigestEnabled else {
            notificationManager.cancelNotification(id: Self.dailyDigestNotificationID)
            return
        }
        let total = dueFlashcardsCount + dueQuestionsCount
        guard total > 0 else {
            notificationManager.cancelNotification(id: Self.dailyDigestNotificationID)
            return
        }
        notificationManager.scheduleDailyNotification(
            id: Self.dailyDigestNotificationID,
            title: "Review Time",
            body: "\(total) card\(total == 1 ? "" : "s") waiting for review.",
            hour: userPreferences.dailyDigestHour,
            minute: 0
        )
    }
}
