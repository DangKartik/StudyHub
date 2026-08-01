import SwiftData
import SwiftUI

@MainActor
final class AppContainer {
    let appState: AppState
    let userPreferences: UserPreferences
    let modelContainer: ModelContainer
    let navigationRouter: NavigationRouter

    let semesterRepository: any SemesterRepositoryProtocol
    let courseRepository: any CourseRepositoryProtocol
    let lectureRepository: any LectureRepositoryProtocol
    let assignmentRepository: any AssignmentRepositoryProtocol
    let readingRepository: any ReadingRepositoryProtocol
    let resourceRepository: any ResourceRepositoryProtocol
    let flashcardRepository: any FlashcardRepositoryProtocol
    let activeRecallRepository: any ActiveRecallRepositoryProtocol
    let noteRepository: any NoteRepositoryProtocol
    let studySessionRepository: any StudySessionRepositoryProtocol
    let statisticsRepository: any StatisticsRepositoryProtocol
    let quoteRepository: any QuoteRepositoryProtocol
    let calendarRepository: any CalendarRepositoryProtocol
    let bookmarkRepository: any BookmarkRepositoryProtocol
    let pdfProgressRepository: any PDFProgressRepositoryProtocol
    let pdfService: any PDFServiceProtocol

    private let appLifecycleService: any AppLifecycleServicing

    init() {
        let appState = AppState()

        self.appState = appState
        self.userPreferences = UserPreferences()
        self.modelContainer = ModelContainerFactory.makeContainer()
        self.navigationRouter = NavigationRouter()

        let context = modelContainer.mainContext
        semesterRepository = SemesterRepository(modelContext: context)
        courseRepository = CourseRepository(modelContext: context)
        lectureRepository = LectureRepository(modelContext: context)
        assignmentRepository = AssignmentRepository(modelContext: context)
        readingRepository = ReadingRepository(modelContext: context)
        resourceRepository = ResourceRepository(modelContext: context)
        flashcardRepository = FlashcardRepository(modelContext: context)
        activeRecallRepository = ActiveRecallRepository(modelContext: context)
        noteRepository = NoteRepository(modelContext: context)
        studySessionRepository = StudySessionRepository(modelContext: context)
        statisticsRepository = StatisticsRepository(modelContext: context)
        quoteRepository = QuoteRepository(modelContext: context)
        calendarRepository = CalendarRepository(modelContext: context)
        bookmarkRepository = BookmarkRepository(modelContext: context)
        pdfProgressRepository = PDFProgressRepository(modelContext: context)
        pdfService = PDFService()

        appLifecycleService = AppLifecycleService(appState: appState, modelContainer: modelContainer)

        if let activeSemester = try? semesterRepository.fetchActive() {
            appState.update(activeSemester: activeSemester)
        }

        Self.seedQuotesIfNeeded(quoteRepository)
    }

    /// `Quote`/`QuoteRepository` have existed since Phase 2 with no writer
    /// anywhere (confirmed by a full-project search) — dormant scaffolding,
    /// same shape as `StudySession` before Phase 4.3 and `ActiveRecallQuestion`'s
    /// SM-2 fields before Phase 4.4. Home's Study Overview card (which
    /// originally shipped with its own hardcoded quote list before this
    /// fix) is the first real consumer, so this seeds a small starter set
    /// exactly once — only when the table is genuinely empty, never
    /// overwriting anything a user might add later.
    private static func seedQuotesIfNeeded(_ quoteRepository: any QuoteRepositoryProtocol) {
        guard (try? quoteRepository.count()) == 0 else { return }

        let starterQuotes = [
            "Small steps every day add up to big results.",
            "The expert in anything was once a beginner.",
            "Review today so tomorrow is easier.",
            "Consistency beats intensity.",
            "Progress, not perfection.",
            "A little bit of review keeps a lot of forgetting away.",
            "You don't have to be great to start, but you have to start to be great.",
            "Your future self is built by what you do today.",
            "Well begun is half done.",
            "Slow and steady wins the race."
        ]

        for text in starterQuotes {
            try? quoteRepository.create(Quote(text: text))
        }
    }

    func handle(scenePhase: ScenePhase) {
        appLifecycleService.handle(scenePhase: scenePhase)
    }
}
