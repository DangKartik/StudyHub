import SwiftUI

@main
struct StudyHubApp: App {
    @Environment(\.scenePhase) private var scenePhase

    @State private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            RootView(
                appState: container.appState,
                userPreferences: container.userPreferences,
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
                pdfService: container.pdfService,
                quoteRepository: container.quoteRepository,
                calendarRepository: container.calendarRepository,
                notificationManager: container.notificationManager,
                calendarSyncService: container.calendarSyncService
            )
        }
        .onChange(of: scenePhase, initial: true) { _, phase in
            container.handle(scenePhase: phase)
        }
    }
}
