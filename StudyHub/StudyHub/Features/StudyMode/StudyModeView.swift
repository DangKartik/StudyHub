import SwiftUI

/// Study Mode entry point (Phase 4.3, requirement 1) — pick a Course,
/// optionally a Lecture, then start a session. The actual session lives in
/// `StudySessionWorkspaceView`, presented full-screen so there's no
/// navigating back and forth once a session begins (requirement 2).
struct StudyModeView: View {
    let navigationRouter: NavigationRouter
    let courseRepository: any CourseRepositoryProtocol
    let studySessionRepository: any StudySessionRepositoryProtocol
    let readingRepository: any ReadingRepositoryProtocol
    let noteRepository: any NoteRepositoryProtocol
    let flashcardRepository: any FlashcardRepositoryProtocol
    let activeRecallRepository: any ActiveRecallRepositoryProtocol
    let lectureRepository: any LectureRepositoryProtocol
    let bookmarkRepository: any BookmarkRepositoryProtocol
    let pdfProgressRepository: any PDFProgressRepositoryProtocol
    let pdfService: any PDFServiceProtocol
    let userPreferences: UserPreferences
    let notificationManager: any NotificationSchedulingProtocol

    @State private var courses: [Course] = []
    @State private var selectedCourse: Course?
    @State private var selectedLecture: Lecture?
    @State private var activeSession: StudySessionViewModel?
    @State private var showingCoursePicker = false
    @State private var showingLecturePicker = false
    @Environment(\.colorScheme) private var colorScheme

    private var availableLectures: [Lecture] {
        selectedCourse?.lectures.sorted { $0.date < $1.date } ?? []
    }

    var body: some View {
        Group {
            if courses.isEmpty {
                StudyHubEmptyState(
                    icon: "brain.head.profile",
                    title: "No Courses Yet",
                    message: "Add a course before starting a Study Session.",
                    actionTitle: "Go to Courses"
                ) {
                    navigationRouter.selectedDestination = .courses
                }
            } else {
                form
            }
        }
        .navigationTitle("Study Mode")
        .onAppear(perform: loadCourses)
        .fullScreenCover(item: $activeSession) { sessionViewModel in
            StudySessionWorkspaceView(
                sessionViewModel: sessionViewModel,
                noteRepository: noteRepository,
                lectureRepository: lectureRepository,
                flashcardRepository: flashcardRepository,
                activeRecallRepository: activeRecallRepository,
                readingRepository: readingRepository,
                bookmarkRepository: bookmarkRepository,
                pdfProgressRepository: pdfProgressRepository,
                pdfService: pdfService,
                userPreferences: userPreferences,
                notificationManager: notificationManager
            )
        }
    }

    private var form: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                heroIntro

                VStack(alignment: .leading, spacing: 12) {
                    SectionHeaderLabel(title: "Course", icon: "book.closed.fill", tint: .blue)
                    // A `Menu` with a fully custom, card-shaped label
                    // triggered iOS's "zoom into preview" presentation (the
                    // same effect a long-press context menu uses) — the
                    // row's content visually vanished mid-tap. A native
                    // menu-style `Picker` fixed that, but it only renders
                    // as a small left-hugging "value ⌄" cluster with no way
                    // to lay it out full-width. A plain `Button` gets full
                    // control over the row's layout either way; it's paired
                    // with `.popover(arrowEdge:)` rather than
                    // `.confirmationDialog` specifically because a dialog's
                    // position is decided by the system (it was opening
                    // upward, overlapping the hero card above), while a
                    // popover's arrow edge is something we can pin down —
                    // `arrowEdge` names the edge of the *popover* the arrow
                    // sits on, not the anchor, so `.top` (arrow on the
                    // popover's top edge, pointing back up at the row)
                    // is what puts the popover itself below the row.
                    Button {
                        showingCoursePicker = true
                    } label: {
                        pickerRow(value: selectedCourse?.name ?? "Select a Course", isPlaceholder: selectedCourse == nil)
                    }
                    .buttonStyle(.plain)
                    .popover(isPresented: $showingCoursePicker, arrowEdge: .top) {
                        optionList(
                            courses.map { course in (course.name, { selectedCourse = course; selectedLecture = nil }) },
                            dismiss: $showingCoursePicker
                        )
                    }
                }

                if selectedCourse != nil {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeaderLabel(title: "Lecture (Optional)", icon: "list.bullet", tint: .indigo)
                        Button {
                            showingLecturePicker = true
                        } label: {
                            pickerRow(value: selectedLecture?.topic ?? "Whole Course", isPlaceholder: false)
                        }
                        .buttonStyle(.plain)
                        .popover(isPresented: $showingLecturePicker, arrowEdge: .top) {
                            optionList(
                                [("Whole Course", { selectedLecture = nil })] +
                                availableLectures.map { lecture in (lecture.topic, { selectedLecture = lecture }) },
                                dismiss: $showingLecturePicker
                            )
                        }
                    }
                }

                Button {
                    startSession()
                } label: {
                    Label("Start Study Session", systemImage: "play.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedCourse == nil)
            }
            .padding(24)
            .frame(maxWidth: 900)
            .frame(maxWidth: .infinity)
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

    /// A short intro card instead of dropping straight into two bare
    /// pickers on an otherwise-empty page — same hero-card language as
    /// Home's greeting, tinted purple to match the sidebar's Study Mode
    /// icon instead of repeating Home's blue.
    private var heroIntro: some View {
        HStack(spacing: 14) {
            Image(systemName: "brain.head.profile")
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(Color.purple.gradient, in: RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 2) {
                Text("Start a Study Session")
                    .font(.title3.weight(.semibold))
                Text("Pick a course, optionally a lecture, and a focus timer runs alongside your notes, flashcards, and readings.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: colorScheme == .dark
                    ? [Color.purple.opacity(0.35), Color.purple.opacity(0.12)]
                    : [Color.purple.opacity(0.16), Color.purple.opacity(0.03)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: StudyHubMetrics.cardCornerRadius)
        )
    }

    private func pickerRow(value: String, isPlaceholder: Bool) -> some View {
        HStack {
            Text(value)
                .foregroundStyle(isPlaceholder ? .secondary : .primary)
            Spacer()
            Image(systemName: "chevron.up.chevron.down")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: StudyHubMetrics.cardCornerRadius))
        .studyHubCardShadow()
    }

    /// Backing content for the Course/Lecture popovers — a plain list of
    /// tappable rows. Tapping a row both runs its action and dismisses the
    /// popover, since a popover (unlike a confirmation dialog) doesn't
    /// close itself on selection.
    private func optionList(_ options: [(title: String, action: () -> Void)], dismiss: Binding<Bool>) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                if index > 0 {
                    Divider()
                }
                Button {
                    option.action()
                    dismiss.wrappedValue = false
                } label: {
                    Text(option.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        // `.buttonStyle(.plain)` alone hit-tests only the
                        // text's own tight bounding box, not the padded
                        // frame around it — without this, only tapping
                        // directly on the letters worked, not the row.
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .frame(minWidth: 240)
    }

    private func loadCourses() {
        courses = ((try? courseRepository.fetchAll()) ?? []).filter { !$0.isArchived }
    }

    private func startSession() {
        guard let selectedCourse else { return }
        let sessionViewModel = StudySessionViewModel(
            course: selectedCourse,
            lecture: selectedLecture,
            studySessionRepository: studySessionRepository,
            readingRepository: readingRepository,
            pdfProgressRepository: pdfProgressRepository
        )
        sessionViewModel.start()
        activeSession = sessionViewModel
    }
}
