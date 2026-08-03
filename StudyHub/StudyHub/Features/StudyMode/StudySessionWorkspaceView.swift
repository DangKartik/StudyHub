import Combine
import SwiftUI

/// The active Study Session (Phase 4.3, requirements 2-4): a Pomodoro timer,
/// live progress counters, and a single workspace the student switches
/// between PDF/Notes/Flashcards/Active Recall inside — no navigating back
/// out to Courses/Sidebar mid-session. Each tab reuses the exact same
/// course-scoped list view every other part of the app uses (requirement 6:
/// reuse existing repositories, no duplicated logic); this view only adds
/// the small optional callbacks those views already expose for tallying
/// live progress.
struct StudySessionWorkspaceView: View {
    let sessionViewModel: StudySessionViewModel
    let noteRepository: any NoteRepositoryProtocol
    let lectureRepository: any LectureRepositoryProtocol
    let flashcardRepository: any FlashcardRepositoryProtocol
    let activeRecallRepository: any ActiveRecallRepositoryProtocol
    let readingRepository: any ReadingRepositoryProtocol
    let bookmarkRepository: any BookmarkRepositoryProtocol
    let pdfProgressRepository: any PDFProgressRepositoryProtocol
    let pdfService: any PDFServiceProtocol
    let userPreferences: UserPreferences
    let notificationManager: any NotificationSchedulingProtocol

    @State private var timer = PomodoroTimerModel()
    /// Scales the timer readout with the user's Dynamic Type setting
    /// instead of staying pinned regardless of accessibility text size
    /// preferences. Sized to fit inside `ringDiameter` at the default type
    /// size, same idea as before just tuned for the ring instead of a
    /// full-width line of text.
    @ScaledMetric(relativeTo: .largeTitle) private var timerFontSize: CGFloat = 40
    private let ringDiameter: CGFloat = 148
    private let compactRingDiameter: CGFloat = 44
    /// Whether the running/paused timer is showing its full ring (tapped
    /// open) instead of the default compact bar — lets you check progress
    /// at a glance without permanently giving the timer the same space it
    /// had before starting.
    @State private var isTimerExpanded = false
    @State private var selectedTab: StudyWorkspaceTab = .pdf
    @State private var showingEndConfirmation = false
    @State private var showingCustomDuration = false
    @State private var customMinutes = 30
    @State private var completedSession: StudySession?
    @Environment(\.dismiss) private var dismiss

    /// "Pages read" has no direct callback into PDFViewerView (deliberately
    /// — see StudySessionViewModel's doc comment), so it can't update the
    /// instant a page turns. Refreshing only `.onChange(of: selectedTab)`
    /// meant the counter stayed frozen the entire time you stayed on the
    /// PDF tab actually reading — this ticks it every couple seconds
    /// instead, so it keeps up while you're there, not just when you leave.
    private let pagesReadRefreshTimer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                timerBar
                counterBar
                tabSwitcher
                tabContent
            }
            // Without this, the counter card below paints
            // `secondarySystemGroupedBackground` (near-white) directly over
            // the screen's default plain-white background — same
            // invisible-card bug as Home/Course Page had before either got
            // a base background set.
            .background(Color(uiColor: .systemGroupedBackground))
            .onReceive(pagesReadRefreshTimer) { _ in
                if selectedTab == .pdf {
                    sessionViewModel.refreshPagesRead()
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("End Session", role: .destructive) {
                        showingEndConfirmation = true
                    }
                }
            }
            .confirmationDialog(
                "End this Study Session?",
                isPresented: $showingEndConfirmation,
                titleVisibility: .visible
            ) {
                Button("End Session", role: .destructive, action: endSession)
                Button("Cancel", role: .cancel) {}
            }
            .fullScreenCover(item: $completedSession) { session in
                StudySessionSummaryView(session: session, onDone: { dismiss() })
            }
        }
        .interactiveDismissDisabled()
    }

    private var header: some View {
        VStack(spacing: 2) {
            Text(sessionViewModel.course.name)
                .font(.title3.weight(.bold))
            if let lecture = sessionViewModel.lecture {
                Text(lecture.topic)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    // MARK: Pomodoro (requirement 3)

    /// A ring (Clock app's Timer tab) while you're still choosing a
    /// duration, before the session has started — once it's actually
    /// running there's real course content to look at (readings, notes,
    /// flashcards), so the timer collapses to a slim bar instead of
    /// permanently occupying a big ring's worth of vertical space above it.
    private var timerBar: some View {
        Group {
            if timer.isRunning || timer.isPaused {
                if isTimerExpanded {
                    expandedRunningTimer
                } else {
                    compactTimerBar
                }
            } else {
                timerSetup
            }
        }
    }

    private var timerSetup: some View {
        VStack(spacing: 10) {
            timerRing(diameter: ringDiameter, lineWidth: 10)
            durationPicker
            Button {
                timer.start()
            } label: {
                Label("Start", systemImage: "play.fill")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 10)
    }

    /// Tapping the ring expands back to the full view below — reopened on
    /// demand instead of either permanently hogging space (the old always-
    /// on ring) or being stuck tiny with no way to see it bigger again.
    private var expandedRunningTimer: some View {
        VStack(spacing: 12) {
            Button {
                withAnimation { isTimerExpanded = false }
            } label: {
                timerRing(diameter: ringDiameter, lineWidth: 10)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Time remaining \(timer.timeText). Double tap to collapse.")

            HStack(spacing: 16) {
                if timer.isRunning {
                    Button {
                        timer.pause()
                    } label: {
                        Label("Pause", systemImage: "pause.fill")
                    }
                    .buttonStyle(.bordered)
                } else {
                    Button {
                        timer.resume()
                    } label: {
                        Label("Resume", systemImage: "play.fill")
                    }
                    .buttonStyle(.borderedProminent)
                }

                Button {
                    timer.finish()
                } label: {
                    Label("Finish", systemImage: "checkmark")
                }
                .buttonStyle(.bordered)
                .tint(.green)
            }
        }
        .padding(.vertical, 10)
    }

    /// Bumped up from the first pass's 34pt/`.headline` — still far smaller
    /// than the full ring, but legible enough to read at a glance instead
    /// of squinting. Tapping the ring+time re-expands to the full view.
    private var compactTimerBar: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation { isTimerExpanded = true }
            } label: {
                HStack(spacing: 10) {
                    timerRing(diameter: compactRingDiameter, lineWidth: 5)
                    Text(timer.timeText)
                        .font(.title3.weight(.bold))
                        .monospacedDigit()
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Time remaining \(timer.timeText). Double tap to expand.")

            Spacer()

            if timer.isRunning {
                Button {
                    timer.pause()
                } label: {
                    Label("Pause", systemImage: "pause.fill")
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.bordered)
            } else {
                Button {
                    timer.resume()
                } label: {
                    Label("Resume", systemImage: "play.fill")
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderedProminent)
            }

            Button {
                timer.finish()
            } label: {
                Label("Finish", systemImage: "checkmark")
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.bordered)
            .tint(.green)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }

    private func timerRing(diameter: CGFloat, lineWidth: CGFloat) -> some View {
        ZStack {
            Circle()
                .stroke(Color(uiColor: .systemGray5), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: timer.progress)
                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: timer.progress)
            if diameter >= ringDiameter {
                Text(timer.timeText)
                    .font(.system(size: timerFontSize, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .padding(.horizontal, 8)
                    .accessibilityLabel("Time remaining \(timer.timeText)")
            }
        }
        .frame(width: diameter, height: diameter)
        // A `Circle().stroke(...)` is only hit-testable along its thin
        // outline — the interior (where the time text sits, i.e. exactly
        // where you'd naturally tap) wasn't actually part of the button's
        // tappable area at all, which is why re-tapping to collapse the
        // expanded ring wasn't registering.
        .contentShape(Circle())
    }

    private var durationPicker: some View {
        HStack(spacing: 8) {
            ForEach(PomodoroDuration.presets) { duration in
                Button(duration.label) {
                    timer.selectDuration(duration)
                }
                .buttonStyle(.bordered)
                .tint(timer.selectedDuration == duration ? Color.accentColor : Color.secondary)
            }
            Button {
                showingCustomDuration = true
            } label: {
                Label("Custom", systemImage: "slider.horizontal.3")
            }
            .buttonStyle(.bordered)
            .tint(isCustomDurationSelected ? Color.accentColor : Color.secondary)
        }
        .disabled(timer.isRunning || timer.isPaused)
        .popover(isPresented: $showingCustomDuration) {
            VStack(spacing: 12) {
                Text("\(customMinutes) minutes")
                    .font(.headline)
                Stepper("Minutes", value: $customMinutes, in: 5...180, step: 5)
                    .labelsHidden()
                Button("Set") {
                    timer.selectDuration(.custom(minutes: customMinutes))
                    showingCustomDuration = false
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .frame(width: 220)
        }
    }

    private var isCustomDurationSelected: Bool {
        if case .custom = timer.selectedDuration { return true }
        return false
    }

    // MARK: Session Progress (requirement 4)

    /// Deliberately small — this is a passive "what you've done so far"
    /// readout, not the point of the screen. The actual reading/notes/
    /// flashcards content below it is what should get the visual weight,
    /// so this card is sized to stay out of the way rather than compete
    /// with it.
    private var counterBar: some View {
        HStack(spacing: 0) {
            counterItem(icon: "rectangle.stack.fill", value: sessionViewModel.flashcardsReviewedCount, label: "Flashcards", tint: .blue)
            Divider().frame(height: 30)
            counterItem(icon: "questionmark.circle.fill", value: sessionViewModel.questionsAnsweredCount, label: "Questions", tint: .purple)
            Divider().frame(height: 30)
            counterItem(icon: "doc.text.fill", value: sessionViewModel.pagesReadCount, label: "Pages", tint: .orange)
            Divider().frame(height: 30)
            counterItem(icon: "note.text", value: sessionViewModel.notesOpenedCount, label: "Notes", tint: .teal)
        }
        .padding(.vertical, 6)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: StudyHubMetrics.cardCornerRadius))
        .studyHubCardShadow()
        .padding(.horizontal)
        .padding(.vertical, 4)
    }

    /// Icon + label on one line, the count below it — hugs its content
    /// tightly rather than padding out to match the old 3-line layout,
    /// since this is a passive readout and shouldn't compete with the
    /// actual reading/notes/flashcards content below it.
    private func counterItem(icon: String, value: Int, label: String, tint: Color) -> some View {
        VStack(spacing: 1) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundStyle(tint.opacity(0.85))
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Text("\(value)")
                .font(.subheadline.weight(.bold))
                .monospacedDigit()
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Workspace (requirement 2)

    private var tabSwitcher: some View {
        Picker("Workspace", selection: $selectedTab) {
            ForEach(StudyWorkspaceTab.allCases) { tab in
                Label(tab.label, systemImage: tab.icon).tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
        .padding(.horizontal)
        .padding(.vertical, 8)
        .onChange(of: selectedTab) {
            sessionViewModel.refreshPagesRead()
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        Group {
            switch selectedTab {
            case .pdf:
                ReadingListView(
                    course: sessionViewModel.course,
                    readingRepository: readingRepository,
                    bookmarkRepository: bookmarkRepository,
                    pdfProgressRepository: pdfProgressRepository,
                    pdfService: pdfService,
                    notificationManager: notificationManager,
                    userPreferences: userPreferences
                )
            case .notes:
                NotesListView(
                    course: sessionViewModel.course,
                    noteRepository: noteRepository,
                    bookmarkRepository: bookmarkRepository,
                    pdfProgressRepository: pdfProgressRepository,
                    pdfService: pdfService,
                    onNoteOpened: { sessionViewModel.recordNoteOpened() }
                )
            case .flashcards:
                FlashcardListView(
                    course: sessionViewModel.course,
                    noteRepository: noteRepository,
                    lectureRepository: lectureRepository,
                    flashcardRepository: flashcardRepository,
                    bookmarkRepository: bookmarkRepository,
                    pdfProgressRepository: pdfProgressRepository,
                    pdfService: pdfService,
                    onCardReviewed: { sessionViewModel.recordCardReviewed() }
                )
            case .activeRecall:
                ActiveRecallListView(
                    course: sessionViewModel.course,
                    activeRecallRepository: activeRecallRepository,
                    noteRepository: noteRepository,
                    flashcardRepository: flashcardRepository,
                    onQuestionAnswered: { sessionViewModel.recordQuestionAnswered() }
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func endSession() {
        sessionViewModel.refreshPagesRead()
        completedSession = sessionViewModel.endSession(completedPomodoros: timer.completedPomodoros)
    }
}

private enum StudyWorkspaceTab: String, CaseIterable, Identifiable {
    case pdf
    case notes
    case flashcards
    case activeRecall

    var id: String { rawValue }

    var label: String {
        switch self {
        case .pdf: return "Reading"
        case .notes: return "Notes"
        case .flashcards: return "Flashcards"
        case .activeRecall: return "Active Recall"
        }
    }

    var icon: String {
        switch self {
        case .pdf: return "doc.richtext"
        case .notes: return "note.text"
        case .flashcards: return "rectangle.stack"
        case .activeRecall: return "brain.head.profile"
        }
    }
}
