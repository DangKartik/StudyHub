import Foundation

@MainActor
@Observable
final class HomeViewModel {
    private let appState: AppState
    private let courseRepository: any CourseRepositoryProtocol
    private let assignmentRepository: any AssignmentRepositoryProtocol
    private let statisticsRepository: any StatisticsRepositoryProtocol

    private(set) var activeSemester: Semester?
    private(set) var courseCount: Int = 0
    private(set) var assignmentsDueToday: [Assignment] = []
    private(set) var upcomingAssignments: [Assignment] = []
    private(set) var latestStatistics: StatisticsSnapshot?
    private(set) var loadError: StudyHubError?

    init(
        appState: AppState,
        courseRepository: any CourseRepositoryProtocol,
        assignmentRepository: any AssignmentRepositoryProtocol,
        statisticsRepository: any StatisticsRepositoryProtocol
    ) {
        self.appState = appState
        self.courseRepository = courseRepository
        self.assignmentRepository = assignmentRepository
        self.statisticsRepository = statisticsRepository
    }

    var greeting: String {
        switch Calendar.current.component(.hour, from: .now) {
        case 0..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    func loadDashboard() {
        guard let semester = appState.activeSemester else {
            activeSemester = nil
            courseCount = 0
            assignmentsDueToday = []
            upcomingAssignments = []
            latestStatistics = nil
            loadError = nil
            return
        }

        activeSemester = semester

        do {
            let activeCourses = try courseRepository.fetch(forSemester: semester).filter { !$0.isArchived }
            courseCount = activeCourses.count
            let courseIDs = Set(activeCourses.map(\.id))

            var allAssignments: [Assignment] = []
            for course in activeCourses {
                allAssignments.append(contentsOf: try assignmentRepository.fetch(forCourse: course))
            }

            let now = Date.now
            upcomingAssignments = Array(
                allAssignments
                    .filter { $0.status != .completed && $0.dueDate >= now }
                    .sorted { $0.dueDate < $1.dueDate }
                    .prefix(5)
            )

            let dueToday = try assignmentRepository.dueToday()
            assignmentsDueToday = dueToday.filter { assignment in
                guard let courseID = assignment.course?.id else { return false }
                return courseIDs.contains(courseID)
            }

            let snapshots = try statisticsRepository.fetch(forSemester: semester)
            latestStatistics = snapshots.sorted { $0.date > $1.date }.first

            loadError = nil
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.fetchFailed(underlying: error)
        }
    }
}
