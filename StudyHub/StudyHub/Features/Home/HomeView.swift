import SwiftUI

struct HomeView: View {
    let appState: AppState
    let semesterRepository: any SemesterRepositoryProtocol
    let courseRepository: any CourseRepositoryProtocol
    let lectureRepository: any LectureRepositoryProtocol
    let assignmentRepository: any AssignmentRepositoryProtocol
    let readingRepository: any ReadingRepositoryProtocol
    let resourceRepository: any ResourceRepositoryProtocol
    let flashcardRepository: any FlashcardRepositoryProtocol
    let activeRecallRepository: any ActiveRecallRepositoryProtocol
    let noteRepository: any NoteRepositoryProtocol
    let pdfService: any PDFServiceProtocol

    @State private var viewModel: HomeViewModel

    private static let upcomingDueDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()

    init(
        appState: AppState,
        semesterRepository: any SemesterRepositoryProtocol,
        courseRepository: any CourseRepositoryProtocol,
        assignmentRepository: any AssignmentRepositoryProtocol,
        statisticsRepository: any StatisticsRepositoryProtocol,
        lectureRepository: any LectureRepositoryProtocol,
        readingRepository: any ReadingRepositoryProtocol,
        resourceRepository: any ResourceRepositoryProtocol,
        flashcardRepository: any FlashcardRepositoryProtocol,
        activeRecallRepository: any ActiveRecallRepositoryProtocol,
        noteRepository: any NoteRepositoryProtocol,
        pdfService: any PDFServiceProtocol
    ) {
        self.appState = appState
        self.semesterRepository = semesterRepository
        self.courseRepository = courseRepository
        self.lectureRepository = lectureRepository
        self.assignmentRepository = assignmentRepository
        self.readingRepository = readingRepository
        self.resourceRepository = resourceRepository
        self.flashcardRepository = flashcardRepository
        self.activeRecallRepository = activeRecallRepository
        self.noteRepository = noteRepository
        self.pdfService = pdfService
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

            NavigationLink("View Courses") {
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
                    pdfService: pdfService
                )
            }
        }
    }

    @ViewBuilder
    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today")
                .font(.title2.bold())

            if viewModel.assignmentsDueToday.isEmpty {
                StudyHubEmptyState(
                    icon: "checkmark.circle",
                    title: "Nothing Due Today",
                    message: "You're all caught up for today."
                )
            } else {
                ForEach(viewModel.assignmentsDueToday, id: \.id) { assignment in
                    AssignmentSummaryRow(
                        assignment: assignment,
                        dueLabel: "Due: \(assignment.dueDate.formatted(date: .omitted, time: .shortened))"
                    )
                    Divider()
                }
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
                    AssignmentSummaryRow(
                        assignment: assignment,
                        dueLabel: "Due: \(HomeView.upcomingDueDateFormatter.string(from: assignment.dueDate))"
                    )
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

private struct AssignmentSummaryRow: View {
    let assignment: Assignment
    let dueLabel: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(assignment.title)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(assignment.priority.label)
                    .font(.caption)
                    .foregroundStyle(priorityColor)
            }
            if let courseLabel {
                Text(courseLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(dueLabel)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(assignment.title)." +
            (courseLabel.map { " \($0)." } ?? "") +
            " \(dueLabel). \(assignment.priority.label) priority."
        )
    }

    private var courseLabel: String? {
        guard let course = assignment.course else { return nil }
        return course.name.isEmpty ? course.courseCode : course.name
    }

    private var priorityColor: Color {
        switch assignment.priority {
        case .low: return .green
        case .medium: return .blue
        case .high: return .orange
        case .critical: return .red
        }
    }
}
