import SwiftUI

struct AppShellDetailView: View {
    let destination: SidebarDestination?
    let appState: AppState
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
                semesterRepository: semesterRepository,
                courseRepository: courseRepository,
                assignmentRepository: assignmentRepository,
                statisticsRepository: statisticsRepository,
                lectureRepository: lectureRepository,
                readingRepository: readingRepository,
                resourceRepository: resourceRepository,
                flashcardRepository: flashcardRepository,
                activeRecallRepository: activeRecallRepository,
                noteRepository: noteRepository,
                bookmarkRepository: bookmarkRepository,
                pdfProgressRepository: pdfProgressRepository,
                pdfService: pdfService
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
                pdfService: pdfService
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
