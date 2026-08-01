import Foundation

@MainActor
@Observable
final class HomeViewModel {
    private let appState: AppState
    private let userPreferences: UserPreferences
    private let courseRepository: any CourseRepositoryProtocol
    private let assignmentRepository: any AssignmentRepositoryProtocol
    private let flashcardRepository: any FlashcardRepositoryProtocol
    private let activeRecallRepository: any ActiveRecallRepositoryProtocol
    private let studySessionRepository: any StudySessionRepositoryProtocol
    private let quoteRepository: any QuoteRepositoryProtocol

    private(set) var activeSemester: Semester?
    private(set) var courseCount: Int = 0
    private(set) var assignmentsDueToday: [Assignment] = []
    private(set) var upcomingAssignments: [Assignment] = []
    /// Exams (an existing, real per-course feature reached via each
    /// Course's "Grades" tab — not new scaffolding) landing within the
    /// next `nearExamWindowDays`, across every active course. Home only
    /// ever shows the near-term ones; browsing every exam still happens
    /// per-course via Grades.
    private(set) var upcomingExams: [Exam] = []
    private(set) var loadError: StudyHubError?

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

    init(
        appState: AppState,
        userPreferences: UserPreferences,
        courseRepository: any CourseRepositoryProtocol,
        assignmentRepository: any AssignmentRepositoryProtocol,
        flashcardRepository: any FlashcardRepositoryProtocol,
        activeRecallRepository: any ActiveRecallRepositoryProtocol,
        studySessionRepository: any StudySessionRepositoryProtocol,
        quoteRepository: any QuoteRepositoryProtocol
    ) {
        self.appState = appState
        self.userPreferences = userPreferences
        self.courseRepository = courseRepository
        self.assignmentRepository = assignmentRepository
        self.flashcardRepository = flashcardRepository
        self.activeRecallRepository = activeRecallRepository
        self.studySessionRepository = studySessionRepository
        self.quoteRepository = quoteRepository
    }

    func loadDashboard() {
        refreshGreeting()
        loadStudyOverview()

        guard let semester = appState.activeSemester else {
            activeSemester = nil
            courseCount = 0
            assignmentsDueToday = []
            upcomingAssignments = []
            upcomingExams = []
            loadError = nil
            return
        }

        activeSemester = semester

        do {
            let activeCourses = try courseRepository.fetch(forSemester: semester).filter { !$0.isArchived }
            courseCount = activeCourses.count
            let courseIDs = Set(activeCourses.map(\.id))

            var allAssignments: [Assignment] = []
            var allExams: [Exam] = []
            for course in activeCourses {
                allAssignments.append(contentsOf: try assignmentRepository.fetch(forCourse: course))
                allExams.append(contentsOf: try courseRepository.fetchExams(for: course))
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

            loadError = nil
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.fetchFailed(underlying: error)
        }
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
    }
}
