import SwiftUI

/// The Course Page — replaces the old course row's flat strip of 8 buttons
/// with a real per-course dashboard: stats, what's due, what's coming up,
/// and quick access to every existing per-course feature. Nothing is
/// removed — Lectures/Assignments/Readings/Resources/Grades/Flashcards/
/// Active Recall/Notes all still work exactly as before, just reached from
/// here instead of directly off the course row.
struct CourseDetailView: View {
    let course: Course
    let appState: AppState
    let courseRepository: any CourseRepositoryProtocol
    let semesterRepository: any SemesterRepositoryProtocol
    let lectureRepository: any LectureRepositoryProtocol
    let assignmentRepository: any AssignmentRepositoryProtocol
    let readingRepository: any ReadingRepositoryProtocol
    let resourceRepository: any ResourceRepositoryProtocol
    let flashcardRepository: any FlashcardRepositoryProtocol
    let activeRecallRepository: any ActiveRecallRepositoryProtocol
    let noteRepository: any NoteRepositoryProtocol
    let bookmarkRepository: any BookmarkRepositoryProtocol
    let pdfProgressRepository: any PDFProgressRepositoryProtocol
    let pdfService: any PDFServiceProtocol
    let studySessionRepository: any StudySessionRepositoryProtocol
    let userPreferences: UserPreferences
    let calendarRepository: any CalendarRepositoryProtocol
    let notificationManager: any NotificationSchedulingProtocol
    let calendarSyncService: any CalendarSyncServiceProtocol

    @State private var viewModel: CourseDetailViewModel
    /// `sheet(item:)` rather than a bool, matching every other feature's
    /// edit-sheet pattern app-wide (Assignments/Flashcards/Notes/etc all
    /// key their sheet off an Identifiable value, not a separate flag).
    @State private var editingCourse: Course?
    @State private var assignmentForQuickStatus: Assignment?
    @State private var examForQuickView: Assessment?
    @State private var readingForNavigation: Reading?
    @Environment(\.openURL) private var openURL
    @Environment(\.colorScheme) private var colorScheme

    private static let dueDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        return formatter
    }()

    init(
        course: Course,
        appState: AppState,
        courseRepository: any CourseRepositoryProtocol,
        semesterRepository: any SemesterRepositoryProtocol,
        lectureRepository: any LectureRepositoryProtocol,
        assignmentRepository: any AssignmentRepositoryProtocol,
        readingRepository: any ReadingRepositoryProtocol,
        resourceRepository: any ResourceRepositoryProtocol,
        flashcardRepository: any FlashcardRepositoryProtocol,
        activeRecallRepository: any ActiveRecallRepositoryProtocol,
        noteRepository: any NoteRepositoryProtocol,
        bookmarkRepository: any BookmarkRepositoryProtocol,
        pdfProgressRepository: any PDFProgressRepositoryProtocol,
        pdfService: any PDFServiceProtocol,
        studySessionRepository: any StudySessionRepositoryProtocol,
        userPreferences: UserPreferences,
        calendarRepository: any CalendarRepositoryProtocol,
        notificationManager: any NotificationSchedulingProtocol,
        calendarSyncService: any CalendarSyncServiceProtocol
    ) {
        self.course = course
        self.appState = appState
        self.courseRepository = courseRepository
        self.semesterRepository = semesterRepository
        self.lectureRepository = lectureRepository
        self.assignmentRepository = assignmentRepository
        self.readingRepository = readingRepository
        self.resourceRepository = resourceRepository
        self.flashcardRepository = flashcardRepository
        self.activeRecallRepository = activeRecallRepository
        self.noteRepository = noteRepository
        self.bookmarkRepository = bookmarkRepository
        self.pdfProgressRepository = pdfProgressRepository
        self.pdfService = pdfService
        self.studySessionRepository = studySessionRepository
        self.userPreferences = userPreferences
        self.calendarRepository = calendarRepository
        self.notificationManager = notificationManager
        self.calendarSyncService = calendarSyncService
        _viewModel = State(wrappedValue: CourseDetailViewModel(
            course: course,
            courseRepository: courseRepository,
            readingRepository: readingRepository,
            pdfProgressRepository: pdfProgressRepository,
            flashcardRepository: flashcardRepository,
            activeRecallRepository: activeRecallRepository,
            assignmentRepository: assignmentRepository,
            studySessionRepository: studySessionRepository
        ))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if let error = viewModel.loadError {
                    Text(error.message)
                        .foregroundStyle(.red)
                }

                header

                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                } else {
                    statsSection

                    if viewModel.upcomingAssignment != nil || viewModel.upcomingExam != nil || viewModel.upcomingReading != nil {
                        upcomingSection
                    }
                }

                quickLinksSection
            }
            .padding(24)
            .frame(maxWidth: 900)
            // Same fix as Home: cap the width, then center the capped
            // content — without the second frame it just hugs the leading
            // edge on a wide iPad, which is also why the quick-link badges
            // (pinned to their row's trailing edge via `Spacer()`) used to
            // end up stranded far from their own row's text.
            .frame(maxWidth: .infinity)
        }
        // The page previously had no background at all (plain
        // `.systemBackground`, i.e. white) — every "card" below is painted
        // `secondarySystemGroupedBackground`, which is *also* white against
        // a plain white page, so every card was invisible. Matches Home's
        // ScrollView background now, which is what actually makes the
        // cards read as cards.
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(course.name.isEmpty ? course.courseCode : course.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if course.emailableInstructors.count > 1 {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        ForEach(course.emailableInstructors, id: \.url) { entry in
                            Button(entry.name) {
                                openURL(entry.url)
                            }
                        }
                    } label: {
                        Label("Email Instructor", systemImage: "envelope")
                    }
                }
            } else if let entry = course.emailableInstructors.first {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        openURL(entry.url)
                    } label: {
                        Label("Email Instructor", systemImage: "envelope")
                    }
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { editingCourse = course }
            }
        }
        .sheet(item: $editingCourse) { course in
            CourseFormView(
                viewModel: CoursesViewModel(appState: appState, courseRepository: courseRepository, semesterRepository: semesterRepository),
                course: course
            )
        }
        .sheet(isPresented: Binding(
            get: { assignmentForQuickStatus != nil },
            set: { isPresented in
                if !isPresented { assignmentForQuickStatus = nil }
            }
        ), onDismiss: {
            viewModel.load()
        }) {
            if let assignmentForQuickStatus {
                AssignmentQuickStatusView(
                    viewModel: AssignmentsViewModel(course: course, assignmentRepository: assignmentRepository, notificationManager: notificationManager, calendarSyncService: calendarSyncService, calendarRepository: calendarRepository, userPreferences: userPreferences),
                    assignment: assignmentForQuickStatus
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
            // Reading has no standalone detail screen — every entry point
            // opens it via its Course's Reading list, whose own row already
            // knows how to open the PDF/link.
            ReadingListView(
                course: course,
                readingRepository: readingRepository,
                bookmarkRepository: bookmarkRepository,
                pdfProgressRepository: pdfProgressRepository,
                pdfService: pdfService,
                notificationManager: notificationManager,
                userPreferences: userPreferences
            )
        }
        .onAppear {
            viewModel.load()
        }
        .onReceive(NotificationCenter.default.publisher(for: .readingsDidChange)) { _ in
            viewModel.load()
        }
    }

    /// The course name lives in the nav title now (see `navigationTitle`
    /// below) — repeating it again here was redundant, so the body header
    /// leads with Professor (the more useful "who's teaching this" context)
    /// and Course Code below it. Reworked into a hero band tinted by the
    /// course's own color (same gradient-card language as Home's greeting)
    /// instead of a plain text stack with a small dot — gives each course's
    /// page its own visual identity instead of every course page looking
    /// identical.
    private var header: some View {
        HStack(spacing: 14) {
            Image(systemName: "book.closed.fill")
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(Color.courseColor(from: course.courseColor).gradient, in: RoundedRectangle(cornerRadius: 14))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                if !course.instructorDisplayName.isEmpty {
                    Text(course.instructorDisplayName)
                        .font(.title3.weight(.semibold))
                }
                if !course.courseCode.isEmpty {
                    Text(course.courseCode)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: colorScheme == .dark
                    ? [Color.courseColor(from: course.courseColor).opacity(0.35), Color.courseColor(from: course.courseColor).opacity(0.12)]
                    : [Color.courseColor(from: course.courseColor).opacity(0.16), Color.courseColor(from: course.courseColor).opacity(0.03)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: StudyHubMetrics.cardCornerRadius)
        )
        .accessibilityElement(children: .combine)
    }

    private var statsSection: some View {
        HStack(spacing: 0) {
            CourseStatCard(icon: "clock.fill", value: StudyTimeFormatter.label(minutes: viewModel.totalStudyMinutes), label: "Time Spent", tint: .orange)
            Divider().padding(.vertical, 12)
            CourseStatCard(icon: "rectangle.stack.fill", value: "\(viewModel.dueFlashcardsCount)", label: "Flashcards Due", tint: .blue)
            Divider().padding(.vertical, 12)
            CourseStatCard(icon: "brain.head.profile", value: "\(viewModel.dueQuestionsCount)", label: "Questions Due", tint: .purple)
            Divider().padding(.vertical, 12)
            CourseStatCard(icon: "book.fill", value: viewModel.readingProgressPercent.map { "\(Int($0))%" } ?? "—", label: "Reading Progress", tint: .green)
        }
        .padding(.vertical, 16)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: StudyHubMetrics.cardCornerRadius))
        .studyHubCardShadow()
    }

    /// Same tinted-icon-badge language as Home's section headers — kept in
    /// sync deliberately rather than sharing one file, since Home's version
    /// also drives its own empty-state navigation destinations.
    private func sectionHeader(_ title: String, icon: String, tint: Color) -> some View {
        SectionHeaderLabel(title: title, icon: icon, tint: tint)
    }

    /// Assignment and exam are each independently "the soonest one of that
    /// type" (see `CourseDetailViewModel.load()`) — rendering them in a
    /// fixed assignment-then-exam order meant an exam happening tomorrow
    /// could show below an assignment due in a week. Sorted here by actual
    /// date instead, so whichever is genuinely soonest is on top.
    private enum UpcomingItem: Identifiable {
        case assignment(Assignment)
        case exam(Assessment)
        case reading(Reading)

        var id: String {
            switch self {
            case .assignment(let assignment): return "assignment-\(assignment.id)"
            case .exam(let exam): return "exam-\(exam.id)"
            case .reading(let reading): return "reading-\(reading.id)"
            }
        }

        var sortDate: Date {
            switch self {
            case .assignment(let assignment): return assignment.dueDate
            case .exam(let exam): return exam.date
            case .reading(let reading): return reading.dueDate ?? .distantFuture
            }
        }
    }

    private var upcomingItems: [UpcomingItem] {
        var items: [UpcomingItem] = []
        if let assignment = viewModel.upcomingAssignment { items.append(.assignment(assignment)) }
        if let exam = viewModel.upcomingExam { items.append(.exam(exam)) }
        if let reading = viewModel.upcomingReading { items.append(.reading(reading)) }
        return items.sorted { $0.sortDate < $1.sortDate }
    }

    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Upcoming", icon: "clock.fill", tint: .orange)

            ForEach(upcomingItems) { item in
                switch item {
                case .assignment(let assignment):
                    AssignmentSummaryRow(
                        assignment: assignment,
                        dueLabel: "Due \(Self.dueDateFormatter.string(from: assignment.dueDate))",
                        showsChevron: true
                    )
                    .padding(16)
                    .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: StudyHubMetrics.cardCornerRadius))
                    .studyHubCardShadow()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        assignmentForQuickStatus = assignment
                    }
                    .accessibilityAddTraits(.isButton)
                case .exam(let exam):
                    ExamSummaryRow(exam: exam, showsChevron: true)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            examForQuickView = exam
                        }
                        .accessibilityAddTraits(.isButton)
                case .reading(let reading):
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

    /// Ordered by how often each is actually opened day-to-day — active
    /// study tools (Flashcards/Active Recall/Notes/Readings) first, then
    /// tracking (Assignments/Lectures), then the more occasional reference
    /// sections (Resources/Grades) last. Was previously in whatever order
    /// the code happened to declare them, not usage.
    /// A gallery of cards (Files/Settings-app-style) instead of a plain
    /// vertical link list — four per row so all eight sections read as one
    /// glanceable grid rather than a long scroll of identical-height rows.
    /// Ordering (active study tools first, tracking next, reference last)
    /// carries over unchanged from the old list.
    private var quickLinksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Course Sections", icon: "square.grid.2x2.fill", tint: .indigo)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4), spacing: 16) {
                NavigationLink {
                    FlashcardListView(
                        course: course,
                        noteRepository: noteRepository,
                        lectureRepository: lectureRepository,
                        flashcardRepository: flashcardRepository,
                        bookmarkRepository: bookmarkRepository,
                        pdfProgressRepository: pdfProgressRepository,
                        pdfService: pdfService
                    )
                } label: {
                    CourseSectionCard(icon: "rectangle.stack.fill", title: "Flashcards", tint: .blue, badge: viewModel.dueFlashcardsCount)
                }

                NavigationLink {
                    ActiveRecallListView(
                        course: course,
                        activeRecallRepository: activeRecallRepository,
                        noteRepository: noteRepository,
                        flashcardRepository: flashcardRepository
                    )
                } label: {
                    CourseSectionCard(icon: "brain.head.profile", title: "Active Recall", tint: .purple, badge: viewModel.dueQuestionsCount)
                }

                NavigationLink {
                    NotesListView(
                        course: course,
                        noteRepository: noteRepository,
                        bookmarkRepository: bookmarkRepository,
                        pdfProgressRepository: pdfProgressRepository,
                        pdfService: pdfService
                    )
                } label: {
                    CourseSectionCard(icon: "note.text", title: "Notes", tint: .teal)
                }

                NavigationLink {
                    ReadingListView(
                        course: course,
                        readingRepository: readingRepository,
                        bookmarkRepository: bookmarkRepository,
                        pdfProgressRepository: pdfProgressRepository,
                        pdfService: pdfService,
                        notificationManager: notificationManager,
                        userPreferences: userPreferences
                    )
                } label: {
                    CourseSectionCard(icon: "book.fill", title: "Readings", tint: .orange)
                }

                NavigationLink {
                    AssignmentListView(
                        course: course,
                        assignmentRepository: assignmentRepository,
                        bookmarkRepository: bookmarkRepository,
                        pdfProgressRepository: pdfProgressRepository,
                        pdfService: pdfService,
                        notificationManager: notificationManager,
                        calendarSyncService: calendarSyncService,
                        calendarRepository: calendarRepository,
                        userPreferences: userPreferences
                    )
                } label: {
                    CourseSectionCard(icon: "checklist", title: "Assignments", tint: .indigo)
                }

                NavigationLink {
                    LectureListView(
                        course: course,
                        lectureRepository: lectureRepository,
                        activeRecallRepository: activeRecallRepository,
                        flashcardRepository: flashcardRepository,
                        noteRepository: noteRepository,
                        bookmarkRepository: bookmarkRepository,
                        pdfProgressRepository: pdfProgressRepository,
                        pdfService: pdfService,
                        userPreferences: userPreferences
                    )
                } label: {
                    CourseSectionCard(icon: "list.bullet", title: "Lectures", tint: .pink)
                }

                NavigationLink {
                    ResourceListView(
                        course: course,
                        resourceRepository: resourceRepository,
                        bookmarkRepository: bookmarkRepository,
                        pdfProgressRepository: pdfProgressRepository,
                        pdfService: pdfService
                    )
                } label: {
                    CourseSectionCard(icon: "folder.fill", title: "Resources", tint: .brown)
                }

                NavigationLink {
                    GradesListView(
                        course: course,
                        courseRepository: courseRepository,
                        bookmarkRepository: bookmarkRepository,
                        pdfProgressRepository: pdfProgressRepository,
                        pdfService: pdfService,
                        notificationManager: notificationManager,
                        calendarSyncService: calendarSyncService,
                        calendarRepository: calendarRepository,
                        userPreferences: userPreferences
                    )
                } label: {
                    CourseSectionCard(icon: "chart.bar.fill", title: "Grades & Exams", tint: .green)
                }
            }
            // Without this, a plain `NavigationLink` label still inherits
            // the system's link/accent tint (that's what was turning every
            // card's title text blue before) — `.plain` hands full control
            // of text/icon color back to each card.
            .buttonStyle(.plain)
        }
    }
}

/// One stat in the Course Page's stats card — icon, rounded-design bold
/// value, caption label. Mirrors Home's `StudyOverviewStatCard` rather than
/// the shared `AnalyticsStatGrid` (plain number + label, no icon) so this
/// page's stats read with the same richness as Home's instead of looking
/// like a stripped-down version of it.
private struct CourseStatCard: View {
    let icon: String
    let value: String
    let label: String
    let tint: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(tint.opacity(0.85))
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

/// One row in the Course Page's quick-links list — a colored icon badge
/// (Settings/Reminders-style, one hue per feature so the list reads as a
/// set of distinct destinations rather than eight identical blue glyphs),
/// title, an optional due-count badge (only shown when > 0), and a
/// chevron. Plain `NavigationLink` styling handles the tap/press feedback;
/// this is just the label content.
private struct CourseSectionCard: View {
    let icon: String
    let title: String
    let tint: Color
    var badge: Int? = nil

    var body: some View {
        VStack(spacing: 10) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: icon)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(tint.gradient, in: RoundedRectangle(cornerRadius: 14))
                    .accessibilityHidden(true)

                // A red app-icon-style badge instead of the accent-color
                // capsule the list-row version used — this is a grid of
                // icon tiles now, so the familiar "unread count on a Home
                // Screen icon" badge reads more naturally here than a pill
                // would.
                if let badge, badge > 0 {
                    Text("\(badge)")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                        .padding(6)
                        .background(Color.red, in: Circle())
                        .offset(x: 8, y: -8)
                        .accessibilityHidden(true)
                }
            }

            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: StudyHubMetrics.cardCornerRadius))
        .studyHubCardShadow()
        .contentShape(RoundedRectangle(cornerRadius: StudyHubMetrics.cardCornerRadius))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(badge.map { $0 > 0 ? "\(title), \($0) due" : title } ?? title)
    }
}
