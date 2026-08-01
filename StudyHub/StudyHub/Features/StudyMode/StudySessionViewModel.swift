import Foundation

/// Orchestrates one Study Session (Phase 4.3, requirement 6: "StudySession
/// should orchestrate, not own") — creates and ends the `StudySession`
/// record via `StudySessionRepository`, and tracks the four live session
/// counters. It never duplicates ownership of the reviewed content itself:
/// Flashcards/Active Recall questions/Notes keep their own existing
/// repositories as the source of truth, this just tallies how many times
/// each kind of action happened during this particular session.
/// Conforms to `Identifiable` (via reference identity) so `StudyModeView`
/// can present the workspace with `.fullScreenCover(item:)` — a fresh
/// instance per session guarantees a fresh view identity, avoiding the
/// `(isPresented:) + a mutated value` re-entrancy trap documented at
/// `FlashcardListView`'s equivalent `.fullScreenCover(item:)` call site.
@MainActor
@Observable
final class StudySessionViewModel: Identifiable {
    nonisolated var id: ObjectIdentifier { ObjectIdentifier(self) }

    let course: Course
    let lecture: Lecture?

    private let studySessionRepository: any StudySessionRepositoryProtocol
    private let readingRepository: any ReadingRepositoryProtocol
    private let pdfProgressRepository: any PDFProgressRepositoryProtocol

    private(set) var session: StudySession?
    private(set) var loadError: StudyHubError?

    private(set) var flashcardsReviewedCount = 0
    private(set) var questionsAnsweredCount = 0
    private(set) var notesOpenedCount = 0
    private(set) var pagesReadCount = 0

    /// Sum of `PDFProgress.highestPageIndex` across the Course's Readings,
    /// captured when the session starts — "pages read" is the difference
    /// between that and the current sum, computed without touching
    /// PDFViewerView/PDFViewerViewModel at all (see DECISION-037).
    private var pagesBaseline = 0

    init(
        course: Course,
        lecture: Lecture?,
        studySessionRepository: any StudySessionRepositoryProtocol,
        readingRepository: any ReadingRepositoryProtocol,
        pdfProgressRepository: any PDFProgressRepositoryProtocol
    ) {
        self.course = course
        self.lecture = lecture
        self.studySessionRepository = studySessionRepository
        self.readingRepository = readingRepository
        self.pdfProgressRepository = pdfProgressRepository
    }

    func start() {
        let newSession = StudySession(startTime: .now)
        newSession.course = course
        newSession.lecture = lecture

        do {
            try studySessionRepository.create(newSession)
            session = newSession
            loadError = nil
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }

        pagesBaseline = currentTotalPagesRead()
    }

    func recordCardReviewed() {
        flashcardsReviewedCount += 1
    }

    func recordQuestionAnswered() {
        questionsAnsweredCount += 1
    }

    func recordNoteOpened() {
        notesOpenedCount += 1
    }

    /// Called whenever the workspace tab changes (and once more at session
    /// end) — recomputes the pages-read delta against the session-start
    /// baseline. Not a live per-page-turn counter, but reacts every time the
    /// student actually checks their progress or moves to another tab.
    func refreshPagesRead() {
        pagesReadCount = max(0, currentTotalPagesRead() - pagesBaseline)
    }

    /// `highestPageIndex` is 0-based (page 1 is index 0), so the number of
    /// pages actually read through that point is `index + 1` — matching the
    /// same `+ 1` convention `ReadingListView` already uses for its own
    /// progress percentage. A Reading with no `PDFProgress` row yet (never
    /// opened) contributes 0, not `0 + 1` — there's no index to convert
    /// until the first page has actually been viewed.
    private func currentTotalPagesRead() -> Int {
        let readings = (try? readingRepository.fetch(forCourse: course)) ?? []
        return readings.reduce(0) { total, reading in
            guard let pdfAttachment = reading.attachments.first(where: { AttachmentKind(rawValue: $0.type) == .pdf }) else {
                return total
            }
            guard let progress = try? pdfProgressRepository.fetch(sourceURL: pdfAttachment.url) else {
                return total
            }
            return total + progress.highestPageIndex + 1
        }
    }

    @discardableResult
    func endSession(completedPomodoros: Int) -> StudySession? {
        guard let session else { return nil }

        refreshPagesRead()

        let endTime = Date.now
        session.endTime = endTime
        session.duration = endTime.timeIntervalSince(session.startTime)
        session.completedPomodoros = completedPomodoros
        session.flashcardsReviewedCount = flashcardsReviewedCount
        session.questionsAnsweredCount = questionsAnsweredCount
        session.pagesReadCount = pagesReadCount
        session.notesOpenedCount = notesOpenedCount

        do {
            try studySessionRepository.save()
            loadError = nil
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }

        return session
    }
}
