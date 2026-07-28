import SwiftData
import SwiftUI

@MainActor
final class AppContainer {
    let appState: AppState
    let modelContainer: ModelContainer

    let semesterRepository: any SemesterRepositoryProtocol
    let courseRepository: any CourseRepositoryProtocol
    let lectureRepository: any LectureRepositoryProtocol
    let assignmentRepository: any AssignmentRepositoryProtocol
    let readingRepository: any ReadingRepositoryProtocol
    let resourceRepository: any ResourceRepositoryProtocol
    let flashcardRepository: any FlashcardRepositoryProtocol
    let activeRecallRepository: any ActiveRecallRepositoryProtocol
    let studySessionRepository: any StudySessionRepositoryProtocol
    let statisticsRepository: any StatisticsRepositoryProtocol
    let quoteRepository: any QuoteRepositoryProtocol
    let calendarRepository: any CalendarRepositoryProtocol

    private let appLifecycleService: any AppLifecycleServicing

    init() {
        let appState = AppState()

        self.appState = appState
        self.modelContainer = ModelContainerFactory.makeContainer()

        let context = modelContainer.mainContext
        semesterRepository = SemesterRepository(modelContext: context)
        courseRepository = CourseRepository(modelContext: context)
        lectureRepository = LectureRepository(modelContext: context)
        assignmentRepository = AssignmentRepository(modelContext: context)
        readingRepository = ReadingRepository(modelContext: context)
        resourceRepository = ResourceRepository(modelContext: context)
        flashcardRepository = FlashcardRepository(modelContext: context)
        activeRecallRepository = ActiveRecallRepository(modelContext: context)
        studySessionRepository = StudySessionRepository(modelContext: context)
        statisticsRepository = StatisticsRepository(modelContext: context)
        quoteRepository = QuoteRepository(modelContext: context)
        calendarRepository = CalendarRepository(modelContext: context)

        appLifecycleService = AppLifecycleService(appState: appState, modelContainer: modelContainer)

        if let activeSemester = try? semesterRepository.fetchActive() {
            appState.update(activeSemester: activeSemester)
        }
    }

    func handle(scenePhase: ScenePhase) {
        appLifecycleService.handle(scenePhase: scenePhase)
    }
}
