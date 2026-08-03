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
    @State private var showSemestersFromEmptyState = false
    @State private var showCoursesFromEmptyState = false
    @State private var assignmentForEdit: Assignment?
    @State private var examForQuickView: Assessment?
    @State private var readingForNavigation: Reading?
    @Environment(\.colorScheme) private var colorScheme

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
            readingRepository: readingRepository,
            flashcardRepository: flashcardRepository,
            activeRecallRepository: activeRecallRepository,
            studySessionRepository: studySessionRepository,
            quoteRepository: quoteRepository
        ))
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                dashboard
            }
        }
        .onAppear {
            viewModel.loadDashboard()
        }
        .onReceive(NotificationCenter.default.publisher(for: .readingsDidChange)) { _ in
            viewModel.loadDashboard()
        }
        .navigationDestination(isPresented: $showSemestersFromEmptyState) {
            SemesterListView(
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
                pdfService: pdfService,
                studySessionRepository: studySessionRepository,
                userPreferences: userPreferences
            )
        }
        .navigationDestination(isPresented: $showCoursesFromEmptyState) {
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
                pdfService: pdfService,
                studySessionRepository: studySessionRepository,
                userPreferences: userPreferences
            )
        }
        .sheet(isPresented: Binding(
            get: { assignmentForEdit != nil },
            set: { isPresented in
                if !isPresented { assignmentForEdit = nil }
            }
        ), onDismiss: {
            viewModel.loadDashboard()
        }) {
            if let assignmentForEdit, let course = assignmentForEdit.course {
                AssignmentQuickStatusView(
                    viewModel: AssignmentsViewModel(course: course, assignmentRepository: assignmentRepository),
                    assignment: assignmentForEdit
                )
            }
        }
        .sheet(isPresented: Binding(
            get: { examForQuickView != nil },
            set: { isPresented in
                if !isPresented { examForQuickView = nil }
            }
        )) {
            if let examForQuickView {
                AssessmentQuickView(assessment: examForQuickView)
            }
        }
        .navigationDestination(isPresented: Binding(
            get: { readingForNavigation != nil },
            set: { isPresented in
                if !isPresented { readingForNavigation = nil }
            }
        )) {
            // Reading has no standalone detail screen anywhere in the app
            // (same reasoning as `GlobalSearchView`'s reading destination)
            // — every entry point opens it via its Course's Reading list,
            // whose own row already knows how to open the PDF/link.
            if let readingForNavigation, let course = readingForNavigation.course {
                ReadingListView(
                    course: course,
                    readingRepository: readingRepository,
                    bookmarkRepository: bookmarkRepository,
                    pdfProgressRepository: pdfProgressRepository,
                    pdfService: pdfService
                )
            }
        }
    }

    private var dashboard: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                if let error = viewModel.loadError {
                    Text(error.message)
                        .foregroundStyle(.red)
                }

                heroSection
                coursesSection
                studyOverviewSection
                if !viewModel.upcomingExams.isEmpty {
                    upcomingExamsSection
                }
                todaySection
                upcomingAssignmentsSection
                if !viewModel.upcomingReadings.isEmpty {
                    upcomingReadingsSection
                }
                statisticsSection
            }
            .padding(24)
            .frame(maxWidth: 900)
            // The cap above only limits width — without this second frame
            // the capped content just hugs the leading edge inside a wider
            // ScrollView, leaving a dead strip on the right (and stranding
            // the scroll indicator out in that empty space). This centers
            // it so the margins are even on both sides.
            .frame(maxWidth: .infinity)
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

    /// The greeting used to sit as plain text directly on the window
    /// background — on a wide iPad landscape screen that reads as an
    /// unfinished, half-empty page. Giving it its own tinted "hero" card
    /// (soft accent gradient, rounded-design display type, a serif italic
    /// quote) is the same composition first-party apps use to make an
    /// otherwise-plain greeting feel considered (Apple Music's "Listen Now"
    /// header, Fitness's Summary card).
    @ViewBuilder
    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(viewModel.greeting)
                .font(.system(.largeTitle, design: .rounded).weight(.heavy))
                .foregroundStyle(.primary)

            Text(viewModel.quoteOfTheDay)
                .font(.system(.title3, design: .serif))
                .italic()
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if let semester = viewModel.activeSemester {
                Label("\(semester.name) · \(viewModel.courseCount) \(viewModel.courseCount == 1 ? "course" : "courses")", systemImage: "calendar")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.accentColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.accentColor.opacity(0.12), in: Capsule())
                    .padding(.top, 4)
            } else {
                StudyHubEmptyState(
                    icon: "calendar.badge.exclamationmark",
                    title: "No Active Semester",
                    message: "Create a semester to start building your dashboard.",
                    actionTitle: "Manage Semesters"
                ) {
                    showSemestersFromEmptyState = true
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            // A light tint wash that reads clearly in Light Mode gets lost
            // against a near-black window background in Dark Mode — bumping
            // the opacity keeps the hero card looking like a deliberate
            // tinted surface rather than washing out to nearly-invisible.
            LinearGradient(
                colors: colorScheme == .dark
                    ? [Color.accentColor.opacity(0.35), Color.accentColor.opacity(0.12)]
                    : [Color.accentColor.opacity(0.16), Color.accentColor.opacity(0.03)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: StudyHubMetrics.cardCornerRadius)
        )
    }

    /// Small icon + title combo used as every section's header — a
    /// consistent "eyebrow" treatment (tinted icon badge, bold title)
    /// instead of bare `Text`, matching how Settings/Health group their
    /// sections rather than just stacking plain headlines.
    private func sectionHeader(_ title: String, icon: String, tint: Color = .accentColor) -> some View {
        SectionHeaderLabel(title: title, icon: icon, tint: tint)
    }

    /// Replaces the old static "View Courses"/"Manage Semesters" buttons —
    /// Manage Semesters is a rare, administrative action (already reachable
    /// from Courses' own toolbar) that doesn't earn a spot on the screen
    /// you open every day. This surfaces actual courses instead, ranked by
    /// how recently you've studied them, same "real data over a bare
    /// button" direction as Study Overview/Upcoming Exams.
    @ViewBuilder
    private var coursesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionHeader("Courses", icon: "book.closed.fill")
                Spacer()
                NavigationLink {
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
                        pdfService: pdfService,
                        studySessionRepository: studySessionRepository,
                        userPreferences: userPreferences
                    )
                } label: {
                    Label("See All", systemImage: "chevron.right")
                        .labelStyle(.trailingIcon)
                }
                .font(.subheadline.weight(.medium))
            }

            if viewModel.recentCourses.isEmpty {
                StudyHubEmptyState(
                    icon: "book.closed",
                    title: "No Courses Yet",
                    message: "Add a course to start organizing your semester.",
                    actionTitle: "Add Course"
                ) {
                    showCoursesFromEmptyState = true
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.recentCourses, id: \.id) { course in
                            NavigationLink {
                                CourseDetailView(
                                    course: course,
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
                                    pdfService: pdfService,
                                    studySessionRepository: studySessionRepository,
                                    userPreferences: userPreferences
                                )
                            } label: {
                                CourseTileView(course: course)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
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
            sectionHeader("Study Overview", icon: "sparkles", tint: .purple)

            HStack(spacing: 0) {
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
                    StudyOverviewStatCard(icon: "rectangle.stack.fill", value: "\(viewModel.dueFlashcardsCount)", label: "Flashcards Due", tint: .blue)
                }
                .buttonStyle(.plain)

                Divider().padding(.vertical, 12)

                NavigationLink {
                    ActiveRecallListView(
                        activeRecallRepository: activeRecallRepository,
                        noteRepository: noteRepository,
                        flashcardRepository: flashcardRepository
                    )
                } label: {
                    StudyOverviewStatCard(icon: "brain.head.profile", value: "\(viewModel.dueQuestionsCount)", label: "Questions Due", tint: .purple)
                }
                .buttonStyle(.plain)

                Divider().padding(.vertical, 12)

                StudyOverviewStatCard(icon: "clock.fill", value: StudyTimeFormatter.label(minutes: viewModel.studyTimeSummary.todayMinutes), label: "Studied Today", tint: .orange)
            }
            .padding(.vertical, 16)
            .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: StudyHubMetrics.cardCornerRadius))
            .studyHubCardShadow()
        }
    }

    @ViewBuilder
    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Today", icon: "calendar.circle.fill", tint: .red)

            if viewModel.assignmentsDueToday.isEmpty {
                celebratoryEmptyState(title: "Nothing Due Today", message: "You're all caught up for today.")
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.assignmentsDueToday.enumerated()), id: \.element.id) { index, assignment in
                        if index > 0 { Divider().padding(.leading, 16) }
                        AssignmentSummaryRow(
                            assignment: assignment,
                            dueLabel: "Due: \(assignment.dueDate.formatted(date: .omitted, time: .shortened))",
                            showsChevron: true
                        )
                        .padding(16)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            assignmentForEdit = assignment
                        }
                        .accessibilityAddTraits(.isButton)
                    }
                }
                .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: StudyHubMetrics.cardCornerRadius))
                .studyHubCardShadow()
            }
        }
    }

    @ViewBuilder
    private var upcomingAssignmentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Upcoming Assignments", icon: "checklist", tint: .indigo)

            if viewModel.upcomingAssignments.isEmpty {
                celebratoryEmptyState(title: "All Caught Up", message: "No upcoming assignments.")
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.upcomingAssignments.enumerated()), id: \.element.id) { index, assignment in
                        if index > 0 { Divider().padding(.leading, 16) }
                        AssignmentSummaryRow(
                            assignment: assignment,
                            dueLabel: "Due: \(HomeView.upcomingDueDateFormatter.string(from: assignment.dueDate))",
                            showsChevron: true
                        )
                        .padding(16)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            assignmentForEdit = assignment
                        }
                        .accessibilityAddTraits(.isButton)
                    }
                }
                .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: StudyHubMetrics.cardCornerRadius))
                .studyHubCardShadow()
            }
        }
    }

    /// A green, filled checkmark badge rather than a plain gray outline —
    /// "you're done" is good news, and first-party apps (Reminders,
    /// Fitness) treat completion states as a small celebratory moment
    /// instead of a neutral placeholder.
    private func celebratoryEmptyState(title: String, message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 40))
                .foregroundStyle(.green)
            Text(title)
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: StudyHubMetrics.cardCornerRadius))
    }

    /// Exams landing within the next two weeks, across every active
    /// course — a "so we can be informed" nudge alongside the existing
    /// Assignments sections, sourced from the same real per-course Exam
    /// data each course's Grades tab already manages.
    @ViewBuilder
    private var upcomingExamsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Upcoming Exam\(viewModel.upcomingExams.count == 1 ? "" : "s")", icon: "graduationcap.fill", tint: .orange)

            VStack(spacing: 8) {
                ForEach(viewModel.upcomingExams, id: \.id) { exam in
                    ExamSummaryRow(exam: exam, showsChevron: true)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            examForQuickView = exam
                        }
                        .accessibilityAddTraits(.isButton)
                }
            }
        }
    }

    /// Readings due today or later, across every active course — same
    /// "real data, near-term" shape as `upcomingExamsSection`. Tapping
    /// opens the reading's own Course Reading list (Reading has no
    /// standalone detail screen anywhere in the app) rather than trying to
    /// open its PDF/link directly from Home.
    @ViewBuilder
    private var upcomingReadingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Upcoming Reading\(viewModel.upcomingReadings.count == 1 ? "" : "s")", icon: "book.fill", tint: .teal)

            VStack(spacing: 8) {
                ForEach(viewModel.upcomingReadings, id: \.id) { reading in
                    ReadingSummaryRow(reading: reading, showsChevron: true)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            readingForNavigation = reading
                        }
                        .accessibilityAddTraits(.isButton)
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
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Study Statistics", icon: "chart.bar.fill", tint: .green)

            if viewModel.studyTimeSummary.weekMinutes == 0 && viewModel.studyTimeSummary.monthMinutes == 0 {
                StudyHubEmptyState(
                    icon: "chart.bar",
                    title: "Not Enough Data",
                    message: "Complete a Study Session to see stats here."
                )
            } else {
                HStack(spacing: 0) {
                    statTile("This Week", StudyTimeFormatter.label(minutes: viewModel.studyTimeSummary.weekMinutes))
                    Divider().padding(.vertical, 12)
                    statTile("This Month", StudyTimeFormatter.label(minutes: viewModel.studyTimeSummary.monthMinutes))
                    Divider().padding(.vertical, 12)
                    statTile("Current Streak", "\(viewModel.studyTimeSummary.currentStreak)d")
                    Divider().padding(.vertical, 12)
                    statTile("Longest Streak", "\(viewModel.studyTimeSummary.longestStreak)d")
                }
                .padding(.vertical, 16)
                .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: StudyHubMetrics.cardCornerRadius))
                .studyHubCardShadow()
            }
        }
    }

    private func statTile(_ label: String, _ value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.title2, design: .rounded).weight(.bold))
                .monospacedDigit()
                .contentTransition(.numericText())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

/// Not `private` — also reused by `CourseDetailView`'s Upcoming section,
/// which doesn't wire up a tap action — `showsChevron` defaults to `false`
/// so that spot doesn't grow a chevron pointing nowhere.
struct AssignmentSummaryRow: View {
    let assignment: Assignment
    let dueLabel: String
    var showsChevron: Bool = false

    var body: some View {
        HStack(spacing: 8) {
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

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
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

/// Not `private` — also reused by `CourseDetailView`'s Upcoming section.
struct ExamSummaryRow: View {
    let exam: Assessment
    var showsChevron: Bool = false

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM 'at' h:mm a"
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
                .symbolRenderingMode(.monochrome)
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
                .padding(.horizontal, StudyHubMetrics.badgeHorizontalPadding)
                .padding(.vertical, StudyHubMetrics.badgeVerticalPadding)
                .background(Color.orange, in: Capsule())

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
        }
        .padding(12)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: StudyHubMetrics.cardCornerRadius))
        .studyHubCardShadow()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(exam.title)." +
            (courseLabel.map { " \($0)." } ?? "") +
            " \(daysAwayLabel), \(Self.dateFormatter.string(from: exam.date))."
        )
    }
}

/// Not `private` for the same reason as `ExamSummaryRow` — kept available
/// in case another screen wants the identical row treatment later.
struct ReadingSummaryRow: View {
    let reading: Reading
    var showsChevron: Bool = false

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter
    }()

    private var courseLabel: String? {
        guard let course = reading.course else { return nil }
        return course.name.isEmpty ? course.courseCode : course.name
    }

    private var daysAwayLabel: String {
        guard let dueDate = reading.dueDate else { return "" }
        let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: .now), to: Calendar.current.startOfDay(for: dueDate)).day ?? 0
        switch days {
        case 0: return "Today"
        case 1: return "Tomorrow"
        default: return "In \(days) days"
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "book.fill")
                .symbolRenderingMode(.monochrome)
                .font(.title3)
                .foregroundStyle(.teal)
                .frame(width: 36, height: 36)
                .background(Color.teal.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(reading.title)
                    .font(.subheadline.weight(.semibold))
                if let courseLabel {
                    Text(courseLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let dueDate = reading.dueDate {
                    Text("Due \(Self.dateFormatter.string(from: dueDate))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text(daysAwayLabel)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, StudyHubMetrics.badgeHorizontalPadding)
                .padding(.vertical, StudyHubMetrics.badgeVerticalPadding)
                .background(Color.teal, in: Capsule())

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
        }
        .padding(12)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: StudyHubMetrics.cardCornerRadius))
        .studyHubCardShadow()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(reading.title)." +
            (courseLabel.map { " \($0)." } ?? "") +
            (reading.dueDate.map { " Due \(daysAwayLabel), \(Self.dateFormatter.string(from: $0))." } ?? "")
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
    let tint: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(tint)
            Text(value)
                .font(.system(.title2, design: .rounded).weight(.bold))
                .monospacedDigit()
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

/// One tile in Home's horizontally-scrolling Courses row — color dot, code,
/// name. Fixed width so several fit on screen at once and line up cleanly
/// regardless of how long a course's name is.
private struct CourseTileView: View {
    let course: Course

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(course.name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            if !course.courseCode.isEmpty {
                Text(course.courseCode)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(width: 140, alignment: .leading)
        .padding(12)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: StudyHubMetrics.cardCornerRadius))
    }
}
