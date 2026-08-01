import SwiftUI

@main
struct StudyHubApp: App {
    @Environment(\.scenePhase) private var scenePhase

    @State private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            RootView(
                appState: container.appState,
                navigationRouter: container.navigationRouter,
                semesterRepository: container.semesterRepository,
                courseRepository: container.courseRepository,
                assignmentRepository: container.assignmentRepository,
                statisticsRepository: container.statisticsRepository,
                lectureRepository: container.lectureRepository,
                readingRepository: container.readingRepository,
                resourceRepository: container.resourceRepository,
                flashcardRepository: container.flashcardRepository,
                activeRecallRepository: container.activeRecallRepository,
                studySessionRepository: container.studySessionRepository,
                noteRepository: container.noteRepository,
                bookmarkRepository: container.bookmarkRepository,
                pdfProgressRepository: container.pdfProgressRepository,
                pdfService: container.pdfService
            )
        }
        .onChange(of: scenePhase, initial: true) { _, phase in
            container.handle(scenePhase: phase)
        }
    }
}
