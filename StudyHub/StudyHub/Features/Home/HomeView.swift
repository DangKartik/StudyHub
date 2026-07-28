import SwiftUI

struct HomeView: View {
    let appState: AppState
    let semesterRepository: any SemesterRepositoryProtocol

    @State private var viewModel: HomeViewModel

    init(
        appState: AppState,
        semesterRepository: any SemesterRepositoryProtocol,
        courseRepository: any CourseRepositoryProtocol,
        assignmentRepository: any AssignmentRepositoryProtocol,
        statisticsRepository: any StatisticsRepositoryProtocol
    ) {
        self.appState = appState
        self.semesterRepository = semesterRepository
        _viewModel = State(wrappedValue: HomeViewModel(
            appState: appState,
            courseRepository: courseRepository,
            assignmentRepository: assignmentRepository,
            statisticsRepository: statisticsRepository
        ))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if let error = viewModel.loadError {
                    Text(error.message)
                        .foregroundStyle(.red)
                }

                semesterSection
                todaySection
                upcomingAssignmentsSection
                statisticsSection
            }
            .padding()
        }
        .onAppear {
            viewModel.loadDashboard()
        }
    }

    @ViewBuilder
    private var semesterSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(viewModel.greeting)
                .font(.largeTitle.bold())

            if let semester = viewModel.activeSemester {
                Text("\(semester.name) · \(viewModel.courseCount) \(viewModel.courseCount == 1 ? "course" : "courses")")
                    .foregroundStyle(.secondary)
            } else {
                StudyHubEmptyState(
                    icon: "calendar.badge.exclamationmark",
                    title: "No Active Semester",
                    message: "Create a semester to start building your dashboard."
                )
            }

            NavigationLink("Manage Semesters") {
                SemesterListView(appState: appState, semesterRepository: semesterRepository)
            }
            .padding(.top, 4)
        }
    }

    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today")
                .font(.title2.bold())

            if viewModel.assignmentsDueToday.isEmpty {
                Text("Nothing due today.")
                    .foregroundStyle(.secondary)
            } else {
                Text(
                    "\(viewModel.assignmentsDueToday.count) " +
                    (viewModel.assignmentsDueToday.count == 1 ? "assignment" : "assignments") +
                    " due today"
                )
            }
        }
    }

    @ViewBuilder
    private var upcomingAssignmentsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Upcoming Assignments")
                .font(.title2.bold())

            if viewModel.upcomingAssignments.isEmpty {
                StudyHubEmptyState(
                    icon: "checkmark.circle",
                    title: "All Caught Up",
                    message: "No upcoming assignments."
                )
            } else {
                ForEach(viewModel.upcomingAssignments, id: \.id) { assignment in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(assignment.title)
                            if let courseName = assignment.course?.name {
                                Text(courseName)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        Text(assignment.dueDate, style: .date)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Divider()
                }
            }
        }
    }

    @ViewBuilder
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Study Statistics")
                .font(.title2.bold())

            if let latest = viewModel.latestStatistics {
                Text("\(latest.studyHours, specifier: "%.1f") hours studied")
            } else {
                StudyHubEmptyState(
                    icon: "chart.bar",
                    title: "Not Enough Data",
                    message: "Not enough study data yet."
                )
            }
        }
    }
}
