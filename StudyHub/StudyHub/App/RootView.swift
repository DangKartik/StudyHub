import SwiftUI

struct RootView: View {
    let appState: AppState
    let userPreferences: UserPreferences
    let navigationRouter: NavigationRouter
    let semesterRepository: any SemesterRepositoryProtocol
    let courseRepository: any CourseRepositoryProtocol
    let assignmentRepository: any AssignmentRepositoryProtocol
    let statisticsRepository: any StatisticsRepositoryProtocol
    let lectureRepository: any LectureRepositoryProtocol
    let readingRepository: any ReadingRepositoryProtocol
    let resourceRepository: any ResourceRepositoryProtocol
    let flashcardRepository: any FlashcardRepositoryProtocol
    let activeRecallRepository: any ActiveRecallRepositoryProtocol
    let studySessionRepository: any StudySessionRepositoryProtocol
    let noteRepository: any NoteRepositoryProtocol
    let bookmarkRepository: any BookmarkRepositoryProtocol
    let pdfProgressRepository: any PDFProgressRepositoryProtocol
    let pdfService: any PDFServiceProtocol
    let quoteRepository: any QuoteRepositoryProtocol

    /// Past, un-reflected assessments (see `Assessment.hasReflected`),
    /// oldest first — presented one at a time so a long-neglected app
    /// doesn't dump every pending reflection on screen at once.
    /// `currentReflection` drives the sheet directly rather than binding to
    /// `pendingReflections.first`, so there's exactly one place
    /// (`advanceReflectionQueue`) that dequeues — including the case where
    /// the sheet is swiped away without answering.
    @State private var pendingReflections: [Assessment] = []
    @State private var currentReflection: Assessment?

    var body: some View {
        AppShellView(
            navigationRouter: navigationRouter,
            appState: appState,
            userPreferences: userPreferences,
            semesterRepository: semesterRepository,
            courseRepository: courseRepository,
            assignmentRepository: assignmentRepository,
            statisticsRepository: statisticsRepository,
            lectureRepository: lectureRepository,
            readingRepository: readingRepository,
            resourceRepository: resourceRepository,
            flashcardRepository: flashcardRepository,
            activeRecallRepository: activeRecallRepository,
            studySessionRepository: studySessionRepository,
            noteRepository: noteRepository,
            bookmarkRepository: bookmarkRepository,
            pdfProgressRepository: pdfProgressRepository,
            pdfService: pdfService,
            quoteRepository: quoteRepository
        )
        .preferredColorScheme(userPreferences.appearance.colorScheme)
        .onAppear {
            loadPendingReflections()
        }
        .sheet(item: $currentReflection, onDismiss: advanceReflectionQueue) { assessment in
            AssessmentReflectionView(
                assessment: assessment,
                onSubmit: { rating, note in
                    assessment.reflectionRating = rating
                    assessment.reflectionNote = note
                    assessment.updatedAt = .now
                    try? courseRepository.save()
                },
                onSkip: {
                    assessment.reflectionDismissedAt = .now
                    try? courseRepository.save()
                }
            )
        }
    }

    /// Scans every course's assessments for ones whose date has already
    /// passed and that haven't been reflected on (or explicitly skipped)
    /// yet — run once when the app's view tree first appears, i.e. on
    /// launch. No push notification yet (deferred); this is the in-app
    /// popup half of that feature.
    private func loadPendingReflections() {
        guard let courses = try? courseRepository.fetchAll() else { return }
        var pending: [Assessment] = []
        for course in courses {
            let assessments = (try? courseRepository.fetchAssessments(for: course)) ?? []
            pending.append(contentsOf: assessments.filter { $0.isPast && !$0.hasReflected })
        }
        pendingReflections = pending.sorted { $0.date < $1.date }
        advanceReflectionQueue()
    }

    /// Pops the next pending reflection into view — called once at launch
    /// and again every time a reflection sheet closes, regardless of
    /// whether it closed via Save, Skip, or being swiped away unanswered
    /// (in which case it simply isn't `hasReflected` yet and will be
    /// re-offered next launch).
    private func advanceReflectionQueue() {
        guard !pendingReflections.isEmpty else {
            currentReflection = nil
            return
        }
        currentReflection = pendingReflections.removeFirst()
    }
}
