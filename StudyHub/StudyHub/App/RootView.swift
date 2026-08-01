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
    }
}
