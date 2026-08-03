import SwiftUI

struct AppShellDetailView: View {
    let destination: SidebarDestination?
    let navigationRouter: NavigationRouter
    let appState: AppState
    let userPreferences: UserPreferences
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

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(destination?.title ?? "StudyHub")
        }
    }

    @ViewBuilder
    private var content: some View {
        switch destination {
        case .home:
            HomeView(
                appState: appState,
                userPreferences: userPreferences,
                semesterRepository: semesterRepository,
                courseRepository: courseRepository,
                assignmentRepository: assignmentRepository,
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
        case .courses:
            CoursesView(
                appState: appState,
                courseRepository: courseRepository,
                semesterRepository: semesterRepository,
                lectureRepository: lectureRepository,
                assignmentRepository: assignmentRepository,
                readingRepository: readingRepository,
                resourceRepository: resourceRepository,
                flashcardRepository: flashcardRepository,
                activeRecallRepository: activeRecallRepository,
                noteRepository: noteRepository,
                bookmarkRepository: bookmarkRepository,
                pdfProgressRepository: pdfProgressRepository,
                pdfService: pdfService,
                studySessionRepository: studySessionRepository,
                userPreferences: userPreferences
            )
        case .notes:
            NotesListView(
                noteRepository: noteRepository,
                bookmarkRepository: bookmarkRepository,
                pdfProgressRepository: pdfProgressRepository,
                pdfService: pdfService
            )
        case .flashcards:
            FlashcardListView(
                noteRepository: noteRepository,
                lectureRepository: lectureRepository,
                flashcardRepository: flashcardRepository,
                bookmarkRepository: bookmarkRepository,
                pdfProgressRepository: pdfProgressRepository,
                pdfService: pdfService
            )
        case .activeRecall:
            ActiveRecallListView(
                activeRecallRepository: activeRecallRepository,
                noteRepository: noteRepository,
                flashcardRepository: flashcardRepository
            )
        case .studyMode:
            StudyModeView(
                navigationRouter: navigationRouter,
                courseRepository: courseRepository,
                studySessionRepository: studySessionRepository,
                readingRepository: readingRepository,
                noteRepository: noteRepository,
                flashcardRepository: flashcardRepository,
                activeRecallRepository: activeRecallRepository,
                lectureRepository: lectureRepository,
                bookmarkRepository: bookmarkRepository,
                pdfProgressRepository: pdfProgressRepository,
                pdfService: pdfService
            )
        case .statistics:
            AnalyticsView(
                appState: appState,
                courseRepository: courseRepository,
                semesterRepository: semesterRepository,
                readingRepository: readingRepository,
                pdfProgressRepository: pdfProgressRepository,
                flashcardRepository: flashcardRepository,
                activeRecallRepository: activeRecallRepository,
                studySessionRepository: studySessionRepository,
                userPreferences: userPreferences
            )
        case .search:
            GlobalSearchView(
                appState: appState,
                semesterRepository: semesterRepository,
                noteRepository: noteRepository,
                flashcardRepository: flashcardRepository,
                activeRecallRepository: activeRecallRepository,
                readingRepository: readingRepository,
                courseRepository: courseRepository,
                bookmarkRepository: bookmarkRepository,
                pdfProgressRepository: pdfProgressRepository,
                pdfService: pdfService
            )
        case .settings:
            SettingsView(userPreferences: userPreferences)
        case .some(let destination):
            StudyHubEmptyState(
                icon: destination.systemImage,
                title: destination.title,
                message: "This section hasn't been built yet."
            )
        case nil:
            StudyHubEmptyState(
                icon: "sidebar.left",
                title: "StudyHub",
                message: "Select a section to get started."
            )
        }
    }
}
