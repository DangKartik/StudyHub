import Foundation

/// Backs the Course Page (replacing the old flat row of 8 buttons on each
/// course) — a real per-course dashboard: how much time you've put into
/// this course, what's due, and quick access to every existing per-course
/// feature (Lectures/Assignments/Readings/Resources/Grades/Flashcards/
/// Active Recall/Notes — none of which are removed, just reached from here
/// instead of the course row directly). Everything computed fresh from
/// existing repositories, same read-only pattern as Analytics/Home.
@MainActor
@Observable
final class CourseDetailViewModel {
    let course: Course

    private let courseRepository: any CourseRepositoryProtocol
    private let readingRepository: any ReadingRepositoryProtocol
    private let pdfProgressRepository: any PDFProgressRepositoryProtocol
    private let flashcardRepository: any FlashcardRepositoryProtocol
    private let activeRecallRepository: any ActiveRecallRepositoryProtocol
    private let assignmentRepository: any AssignmentRepositoryProtocol
    private let studySessionRepository: any StudySessionRepositoryProtocol

    private(set) var loadError: StudyHubError?
    private(set) var isLoading = true
    private(set) var totalStudyMinutes: Int = 0
    private(set) var dueFlashcardsCount: Int = 0
    private(set) var dueQuestionsCount: Int = 0
    /// `nil` when the course has no Readings with real page-count data yet.
    private(set) var readingProgressPercent: Double?
    private(set) var upcomingAssignment: Assignment?
    private(set) var upcomingExam: Assessment?
    private(set) var upcomingReading: Reading?

    init(
        course: Course,
        courseRepository: any CourseRepositoryProtocol,
        readingRepository: any ReadingRepositoryProtocol,
        pdfProgressRepository: any PDFProgressRepositoryProtocol,
        flashcardRepository: any FlashcardRepositoryProtocol,
        activeRecallRepository: any ActiveRecallRepositoryProtocol,
        assignmentRepository: any AssignmentRepositoryProtocol,
        studySessionRepository: any StudySessionRepositoryProtocol
    ) {
        self.course = course
        self.courseRepository = courseRepository
        self.readingRepository = readingRepository
        self.pdfProgressRepository = pdfProgressRepository
        self.flashcardRepository = flashcardRepository
        self.activeRecallRepository = activeRecallRepository
        self.assignmentRepository = assignmentRepository
        self.studySessionRepository = studySessionRepository
    }

    func load() {
        defer { isLoading = false }

        // Recency bump for CoursesView's "most recently opened first"
        // ordering — deliberately not folded into the throwing block below:
        // a failure to persist this shouldn't block the rest of the page
        // from loading, it just means the ordering doesn't update this time.
        course.lastOpenedAt = Date.now
        try? courseRepository.save()

        do {
            let courseID = course.id
            let sessions = try studySessionRepository.fetchAll()
            let totalSeconds = sessions
                .filter { $0.course?.id == courseID || $0.lecture?.course?.id == courseID }
                .reduce(0.0) { $0 + $1.duration }
            totalStudyMinutes = Int(totalSeconds / 60)

            let flashcards = try flashcardRepository.fetch(forCourse: course)
            dueFlashcardsCount = flashcards.filter { DueQueueSection.classify(nextReviewDate: $0.nextReviewDate).isDueNow }.count

            let questions = try activeRecallRepository.fetch(forCourse: course)
            dueQuestionsCount = questions.filter { DueQueueSection.classify(nextReviewDate: $0.nextReviewDate).isDueNow }.count

            readingProgressPercent = try computeReadingProgress()

            let assignments = try assignmentRepository.fetch(forCourse: course)
            let now = Date.now
            upcomingAssignment = assignments
                .filter { $0.status != .completed && $0.dueDate >= now }
                .sorted { $0.dueDate < $1.dueDate }
                .first

            let exams = try courseRepository.fetchAssessments(for: course).filter { $0.kind == .exam }
            upcomingExam = exams
                .filter { $0.date >= now }
                .sorted { $0.date < $1.date }
                .first

            let readings = try readingRepository.fetch(forCourse: course)
            // Calendar-day comparison via `dueStatus`, not a raw timestamp
            // check — see `HomeViewModel.loadDashboard()` for why a plain
            // `dueDate >= now` incorrectly excludes a reading due "today"
            // almost immediately after it's created.
            upcomingReading = readings
                .filter { $0.dueStatus != .notDue }
                .sorted { lhs, rhs in
                    if lhs.dueStatus != rhs.dueStatus {
                        return lhs.dueStatus < rhs.dueStatus
                    }
                    return (lhs.dueDate ?? .distantFuture) < (rhs.dueDate ?? .distantFuture)
                }
                .first

            loadError = nil
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.fetchFailed(underlying: error)
        }
    }

    /// Sums (highestPageIndex+1)/pageCount across the course's Readings —
    /// same Reading -> PDF attachment -> PDFProgress join (looked up by
    /// `sourceURL`, the only key that repository supports) already used
    /// independently in `StudySessionViewModel`/`AnalyticsViewModel`.
    private func computeReadingProgress() throws -> Double? {
        let readings = try readingRepository.fetch(forCourse: course)
        guard !readings.isEmpty else { return nil }

        var readPages = 0
        var totalPages = 0
        for reading in readings {
            guard let pdfAttachment = reading.attachments.first(where: { AttachmentKind(rawValue: $0.type) == .pdf }),
                  let progress = try? pdfProgressRepository.fetch(sourceURL: pdfAttachment.url),
                  progress.pageCount > 0 else { continue }
            readPages += progress.highestPageIndex + 1
            totalPages += progress.pageCount
        }
        guard totalPages > 0 else { return nil }
        return min(100, Double(readPages) / Double(totalPages) * 100)
    }
}
