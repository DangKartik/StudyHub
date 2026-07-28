import SwiftUI

struct RootView: View {
    let appState: AppState
    let navigationRouter: NavigationRouter
    let semesterRepository: any SemesterRepositoryProtocol
    let courseRepository: any CourseRepositoryProtocol
    let assignmentRepository: any AssignmentRepositoryProtocol
    let statisticsRepository: any StatisticsRepositoryProtocol
    let lectureRepository: any LectureRepositoryProtocol

    var body: some View {
        AppShellView(
            navigationRouter: navigationRouter,
            appState: appState,
            semesterRepository: semesterRepository,
            courseRepository: courseRepository,
            assignmentRepository: assignmentRepository,
            statisticsRepository: statisticsRepository,
            lectureRepository: lectureRepository
        )
    }
}
