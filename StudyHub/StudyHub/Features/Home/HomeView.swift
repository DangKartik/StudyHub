import SwiftUI

struct HomeView: View {
    let appState: AppState
    let userPreferences: UserPreferences
    let semesterRepository: any SemesterRepositoryProtocol
    let courseRepository: any CourseRepositoryProtocol
    let lectureRepository: any LectureRepositoryProtocol
    let assignmentRepository: any AssignmentRepositoryProtocol
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

    @State private var viewModel: HomeViewModel

    private static let upcomingDueDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()

    init(
        appState: AppState,
        userPreferences: UserPreferences,
        semesterRepository: any SemesterRepositoryProtocol,
        courseRepository: any CourseRepositoryProtocol,
        assignmentRepository: any AssignmentRepositoryProtocol,
        lectureRepository: any LectureRepositoryProtocol,
        readingRepository: any ReadingRepositoryProtocol,
        resourceRepository: any ResourceRepositoryProtocol,
        flashcardRepository: any FlashcardRepositoryProtocol,
        activeRecallRepository: any ActiveRecallRepositoryProtocol,
        studySessionRepository: any StudySessionRepositoryProtocol,
        noteRepository: any NoteRepositoryProtocol,
        bookmarkRepository: any BookmarkRepositoryProtocol,
        pdfProgressRepository: any PDFProgressRepositoryProtocol,
        pdfService: any PDFServiceProtocol,
        quoteRepository: any QuoteRepositoryProtocol
    ) {
        self.appState = appState
        self.userPreferences = userPreferences
        self.semesterRepository = semesterRepository
        self.courseRepository = courseRepository
        self.lectureRepository = lectureRepository
        self.assignmentRepository = assignmentRepository
        self.readingRepository = readingRepository
        self.resourceRepository = resourceRepository
        self.flashcardRepository = flashcardRepository
        self.activeRecallRepository = activeRecallRepository
        self.studySessionRepository = studySessionRepository
        self.noteRepository = noteRepository
        self.bookmarkRepository = bookmarkRepository
        self.pdfProgressRepository = pdfProgressRepository
        self.pdfService = pdfService
        self.quoteRepository = quoteRepository
        _viewModel = State(wrappedValue: HomeViewModel(
            appState: appState,
            userPreferences: userPreferences,
            courseRepository: courseRepository,
            assignmentRepository: assignmentRepository,
            flashcardRepository: flashcardRepository,
            activeRecallRepository: activeRecallRepository,
            studySessionRepository: studySessionRepository,
            quoteRepository: quoteRepository
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
                studyOverviewSection
                if !viewModel.upcomingExams.isEmpty {
                    upcomingExamsSection
                }
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

            Text(viewModel.quoteOfTheDay)
                .font(.subheadline)
                .italic()
                .foregroundStyle(.secondary)
                .padding(.bottom, 4)

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
                    bookmarkRepository: bookmarkRepository,
                    pdfProgressRepository: pdfProgressRepository,
                    pdfService: pdfService
                )
            }
        }
    }

    /// Study Overview — surfaces Spaced Repetition (Phase 4.4) on Home:
    /// due Flashcards/Active Recall counts (global, so a due card shows up
    /// regardless of which course/semester it belongs to) and today's total
    /// study time. Deliberately lives only here, not on Study Mode's own
    /// landing screen — Home is where the app is opened by default, so
    /// this is the actual nudge to go study; Study Mode's picker screen is
    /// already a deliberate "I'm about to study" action that doesn't need
    /// the same nudge repeated. (The quote moved up below the greeting,
    /// where it reads more like a headline than buried stat-card copy.)
    @ViewBuilder
    private var studyOverviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Study Overview")
                .font(.title2.bold())

            HStack(spacing: 12) {
                NavigationLink {
                    FlashcardListView(
                        noteRepository: noteRepository,
                        lectureRepository: lectureRepository,
                        flashcardRepository: flashcardRepository,
                        bookmarkRepository: bookmarkRepository,
                        pdfProgressRepository: pdfProgressRepository,
                        pdfService: pdfService
                    )
                } label: {
                    StudyOverviewStatCard(icon: "rectangle.stack", value: "\(viewModel.dueFlashcardsCount)", label: "Flashcards Due")
                }

                NavigationLink {
                    ActiveRecallListView(
                        activeRecallRepository: activeRecallRepository,
                        noteRepository: noteRepository,
                        flashcardRepository: flashcardRepository
                    )
                } label: {
                    StudyOverviewStatCard(icon: "brain.head.profile", value: "\(viewModel.dueQuestionsCount)", label: "Questions Due")
                }

                StudyOverviewStatCard(icon: "clock", value: StudyTimeFormatter.label(minutes: viewModel.studyTimeSummary.todayMinutes), label: "Studied Today")
            }
        }
        .buttonStyle(.plain)
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

    /// Exams landing within the next two weeks, across every active
    /// course — a "so we can be informed" nudge alongside the existing
    /// Assignments sections, sourced from the same real per-course Exam
    /// data each course's Grades tab already manages.
    @ViewBuilder
    private var upcomingExamsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Upcoming Exam\(viewModel.upcomingExams.count == 1 ? "" : "s")")
                .font(.title2.bold())

            VStack(spacing: 8) {
                ForEach(viewModel.upcomingExams, id: \.id) { exam in
                    ExamSummaryRow(exam: exam)
                }
            }
        }
    }

    /// Was previously backed by `StatisticsSnapshot`, a dormant model with
    /// no writer anywhere in the codebase — this section always showed its
    /// empty state no matter how much studying happened. Now shares the
    /// same real `StudyTimeSummary` Analytics computes (via
    /// `StudyTimeSummary.compute`), skipping "Today" since the Study
    /// Overview card above already shows it.
    @ViewBuilder
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Study Statistics")
                .font(.title2.bold())

            if viewModel.studyTimeSummary.weekMinutes == 0 && viewModel.studyTimeSummary.monthMinutes == 0 {
                StudyHubEmptyState(
                    icon: "chart.bar",
                    title: "Not Enough Data",
                    message: "Complete a Study Session to see stats here."
                )
            } else {
                HStack {
                    statTile("This Week", StudyTimeFormatter.label(minutes: viewModel.studyTimeSummary.weekMinutes))
                    statTile("This Month", StudyTimeFormatter.label(minutes: viewModel.studyTimeSummary.monthMinutes))
                    statTile("Current Streak", "\(viewModel.studyTimeSummary.currentStreak)d")
                    statTile("Longest Streak", "\(viewModel.studyTimeSummary.longestStreak)d")
                }
            }
        }
    }

    private func statTile(_ label: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title3.bold())
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
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

private struct ExamSummaryRow: View {
    let exam: Exam

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter
    }()

    private var courseLabel: String? {
        guard let course = exam.course else { return nil }
        return course.name.isEmpty ? course.courseCode : course.name
    }

    private var daysAwayLabel: String {
        let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: .now), to: Calendar.current.startOfDay(for: exam.date)).day ?? 0
        switch days {
        case 0: return "Today"
        case 1: return "Tomorrow"
        default: return "In \(days) days"
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "graduationcap.fill")
                .font(.title3)
                .foregroundStyle(.orange)
                .frame(width: 36, height: 36)
                .background(Color.orange.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(exam.title)
                    .font(.subheadline.weight(.semibold))
                if let courseLabel {
                    Text(courseLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(Self.dateFormatter.string(from: exam.date))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(daysAwayLabel)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.orange, in: Capsule())
        }
        .padding(12)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(exam.title)." +
            (courseLabel.map { " \($0)." } ?? "") +
            " \(daysAwayLabel), \(Self.dateFormatter.string(from: exam.date))."
        )
    }
}

/// One stat in the Study Overview row — used both as plain content
/// (`Studied Today`) and as a `NavigationLink` label (`Flashcards Due`/
/// `Questions Due`), so it stays a passive value display either way and
/// leaves tap styling to its container.
private struct StudyOverviewStatCard: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.bold())
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}
