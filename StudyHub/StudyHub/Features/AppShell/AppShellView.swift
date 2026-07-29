import SwiftUI

struct AppShellView: View {
    let navigationRouter: NavigationRouter
    let appState: AppState
    let semesterRepository: any SemesterRepositoryProtocol
    let courseRepository: any CourseRepositoryProtocol
    let assignmentRepository: any AssignmentRepositoryProtocol
    let statisticsRepository: any StatisticsRepositoryProtocol
    let lectureRepository: any LectureRepositoryProtocol
    let readingRepository: any ReadingRepositoryProtocol
    let resourceRepository: any ResourceRepositoryProtocol

    var body: some View {
        NavigationSplitView {
            SidebarView(router: navigationRouter)
        } detail: {
            AppShellDetailView(
                destination: navigationRouter.selectedDestination,
                appState: appState,
                semesterRepository: semesterRepository,
                courseRepository: courseRepository,
                assignmentRepository: assignmentRepository,
                statisticsRepository: statisticsRepository,
                lectureRepository: lectureRepository,
                readingRepository: readingRepository,
                resourceRepository: resourceRepository
            )
        }
    }
}
