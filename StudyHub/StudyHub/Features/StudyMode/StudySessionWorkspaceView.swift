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

    @State private var timer = PomodoroTimerModel()
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
                Divider()
                timerBar
                Divider()
                counterBar
                Divider()
                tabSwitcher
                tabContent
            }
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
                .font(.headline)
            if let lecture = sessionViewModel.lecture {
                Text(lecture.topic)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    // MARK: Pomodoro (requirement 3)

    private var timerBar: some View {
        VStack(spacing: 12) {
            Text(timer.timeText)
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .monospacedDigit()

            ProgressView(value: timer.progress)
                .tint(.accentColor)
                .padding(.horizontal, 40)

            durationPicker
            timerControls
        }
        .padding(.vertical, 12)
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

    private var timerControls: some View {
        HStack(spacing: 16) {
            if timer.isRunning {
                Button {
                    timer.pause()
                } label: {
                    Label("Pause", systemImage: "pause.fill")
                }
                .buttonStyle(.bordered)
            } else if timer.isPaused {
                Button {
                    timer.resume()
                } label: {
                    Label("Resume", systemImage: "play.fill")
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button {
                    timer.start()
                } label: {
                    Label("Start", systemImage: "play.fill")
                }
                .buttonStyle(.borderedProminent)
            }

            if timer.isRunning || timer.isPaused {
                Button {
                    timer.finish()
                } label: {
                    Label("Finish", systemImage: "checkmark")
                }
                .buttonStyle(.bordered)
                .tint(.green)
            }
        }
    }

    // MARK: Session Progress (requirement 4)

    private var counterBar: some View {
        HStack {
            counterItem(icon: "rectangle.stack", value: sessionViewModel.flashcardsReviewedCount, label: "Flashcards")
            Spacer()
            counterItem(icon: "questionmark.circle", value: sessionViewModel.questionsAnsweredCount, label: "Questions")
            Spacer()
            counterItem(icon: "doc.text", value: sessionViewModel.pagesReadCount, label: "Pages")
            Spacer()
            counterItem(icon: "note.text", value: sessionViewModel.notesOpenedCount, label: "Notes")
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }

    private func counterItem(icon: String, value: Int, label: String) -> some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
            Text("\(value)")
                .font(.headline)
                .contentTransition(.numericText())
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
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
                    pdfService: pdfService
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
        case .pdf: return "PDF"
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
