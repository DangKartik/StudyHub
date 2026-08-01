import SwiftUI

struct ActiveRecallListView: View {
    let activeRecallRepository: any ActiveRecallRepositoryProtocol
    /// Phase 4.3 (Study Mode) — invoked once per question rating, so an
    /// embedding Study Session can tally "Questions answered" live. `nil`
    /// everywhere else, zero effect on any existing call site.
    var onQuestionAnswered: (() -> Void)? = nil

    @State private var viewModel: ActiveRecallViewModel
    @State private var activeSheet: ActiveRecallSheet?
    @State private var reviewSession: ActiveRecallReviewSession?
    @State private var sortOrder: ActiveRecallSortOrder = .newestCreated
    @State private var searchText: String = ""
    @State private var selectedTag: String?

    init(
        lecture: Lecture,
        activeRecallRepository: any ActiveRecallRepositoryProtocol,
        noteRepository: any NoteRepositoryProtocol,
        flashcardRepository: any FlashcardRepositoryProtocol
    ) {
        self.activeRecallRepository = activeRecallRepository
        _viewModel = State(wrappedValue: ActiveRecallViewModel(
            scope: .lecture(lecture),
            activeRecallRepository: activeRecallRepository,
            noteRepository: noteRepository,
            flashcardRepository: flashcardRepository
        ))
    }

    init(
        course: Course,
        activeRecallRepository: any ActiveRecallRepositoryProtocol,
        noteRepository: any NoteRepositoryProtocol,
        flashcardRepository: any FlashcardRepositoryProtocol,
        onQuestionAnswered: (() -> Void)? = nil
    ) {
        self.activeRecallRepository = activeRecallRepository
        self.onQuestionAnswered = onQuestionAnswered
        _viewModel = State(wrappedValue: ActiveRecallViewModel(
            scope: .course(course),
            activeRecallRepository: activeRecallRepository,
            noteRepository: noteRepository,
            flashcardRepository: flashcardRepository
        ))
    }

    /// Cross-course "All Questions" browsing (Phase 4.2), mirroring
    /// `FlashcardListView`'s global initializer.
    init(
        activeRecallRepository: any ActiveRecallRepositoryProtocol,
        noteRepository: any NoteRepositoryProtocol,
        flashcardRepository: any FlashcardRepositoryProtocol
    ) {
        self.activeRecallRepository = activeRecallRepository
        _viewModel = State(wrappedValue: ActiveRecallViewModel(
            scope: .global,
            activeRecallRepository: activeRecallRepository,
            noteRepository: noteRepository,
            flashcardRepository: flashcardRepository
        ))
    }

    private var displayedQuestions: [ActiveRecallQuestion] {
        viewModel.displayedQuestions(searchText: searchText, tag: selectedTag, sortOrder: sortOrder)
    }

    /// Phase 4.4 (requirement 3/6) — the subset of `displayedQuestions`
    /// actually due for review right now (due today or never reviewed).
    /// Drives the bulk "Review" button's default instead of reviewing
    /// every question; tapping an individual row still reviews that one
    /// question regardless of due status.
    private var dueQuestions: [ActiveRecallQuestion] {
        viewModel.dueQuestions(from: displayedQuestions)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            Group {
                if viewModel.questions.isEmpty {
                    StudyHubEmptyState(
                        icon: "brain.head.profile",
                        title: "No Recall Questions Yet",
                        message: "Add questions to test your understanding."
                    )
                } else if displayedQuestions.isEmpty {
                    StudyHubEmptyState(
                        icon: "line.3.horizontal.decrease.circle",
                        title: "No Matching Questions",
                        message: "Try a different filter."
                    )
                } else {
                    list
                }
            }
        }
        .navigationTitle("Active Recall")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search Questions")
        .toolbar {
            if viewModel.supportsCreation {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        activeSheet = .create
                    } label: {
                        Label("Add Question", systemImage: "plus")
                    }
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    if !viewModel.allTags.isEmpty {
                        // Not .pickerStyle(.inline) — stays a nested "Tag ›"
                        // submenu, same convention as Notes/Flashcards.
                        Picker("Tag", selection: $selectedTag) {
                            Text("All Tags").tag(String?.none)
                            ForEach(viewModel.allTags, id: \.self) { tag in
                                Text(tag).tag(String?.some(tag))
                            }
                        }
                    }
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .create:
                ActiveRecallFormView(viewModel: viewModel, recallQuestion: nil)
            case .edit(let recallQuestion):
                ActiveRecallFormView(viewModel: viewModel, recallQuestion: recallQuestion)
            }
        }
        // .fullScreenCover(item:) — see FlashcardListView's equivalent
        // comment: (isPresented:) + a separately-mutated array is a SwiftUI
        // trap where the cover's own @State only initializes once per view
        // identity, causing every later session to silently reuse the
        // first one's already-finished state. A fresh Identifiable id per
        // session avoids that from the start here.
        .fullScreenCover(item: $reviewSession) { session in
            ActiveRecallReviewView(questions: session.questions, activeRecallRepository: activeRecallRepository, onRate: onQuestionAnswered)
        }
        .onAppear {
            viewModel.loadQuestions()
        }
    }

    /// Custom title row — matches Notes/Flashcards (Sort on the same line
    /// as the title, system large title suppressed).
    private var header: some View {
        HStack {
            Text("Active Recall")
                .font(.largeTitle)
                .fontWeight(.bold)

            Spacer()

            Menu {
                Picker("Sort", selection: $sortOrder) {
                    ForEach(ActiveRecallSortOrder.allCases) { sortOption in
                        Text(sortOption.label).tag(sortOption)
                    }
                }
                .pickerStyle(.inline)
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var list: some View {
        List {
            if let error = viewModel.loadError {
                Section {
                    Text(error.message)
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button {
                    reviewSession = ActiveRecallReviewSession(questions: dueQuestions)
                } label: {
                    Label("Review \(dueQuestions.count) Due Question\(dueQuestions.count == 1 ? "" : "s")", systemImage: "shuffle")
                }
                .disabled(dueQuestions.isEmpty)
            }

            // Review Queue (Phase 4.4): grouped by the shared SM-2 due-date
            // schedule (Due Today/Due Soon/Future/Never Reviewed), same
            // grouping Flashcards uses.
            ForEach(viewModel.queueSections(from: displayedQuestions), id: \.section) { group in
                Section(group.section.title) {
                    ForEach(group.questions, id: \.id) { recallQuestion in
                        ActiveRecallRowView(recallQuestion: recallQuestion)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                reviewSession = ActiveRecallReviewSession(questions: [recallQuestion])
                            }
                            .accessibilityAddTraits(.isButton)
                            .swipeActions(edge: .trailing) {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    viewModel.deleteQuestion(recallQuestion)
                                }
                                Button("Edit", systemImage: "pencil") {
                                    activeSheet = .edit(recallQuestion)
                                }
                                .tint(.blue)
                            }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

private enum ActiveRecallSheet: Identifiable {
    case create
    case edit(ActiveRecallQuestion)

    var id: String {
        switch self {
        case .create: return "create"
        case .edit(let recallQuestion): return recallQuestion.id.uuidString
        }
    }
}

/// A fresh identity per review pass — see the `.fullScreenCover(item:)`
/// comment in `body`.
private struct ActiveRecallReviewSession: Identifiable {
    let id = UUID()
    let questions: [ActiveRecallQuestion]
}

private struct ActiveRecallRowView: View {
    let recallQuestion: ActiveRecallQuestion

    /// Course name, optionally with the linked Lecture's topic — a
    /// question can now attach directly to a Course with no Lecture
    /// (Phase 4.2, DECISION-036), same shape as Flashcard's row context.
    private var contextText: String? {
        if let lecture = recallQuestion.lecture {
            if let course = lecture.course {
                return "\(course.name) · \(lecture.topic)"
            }
            return lecture.topic
        }
        return recallQuestion.course?.name
    }

    private var rating: RecallRating? {
        RecallRating(rawValue: recallQuestion.difficulty)
    }

    private var statusText: String {
        rating?.label ?? "Never Reviewed"
    }

    private var statusColor: Color {
        switch rating {
        case .again: return .red
        case .hard: return .orange
        case .good: return .blue
        case .easy: return .green
        case nil: return .secondary
        }
    }

    private var lastReviewedText: String {
        guard let lastReviewed = recallQuestion.lastReviewed else { return "Never reviewed" }
        return "Last reviewed \(lastReviewed.formatted(date: .abbreviated, time: .omitted))"
    }

    private static let maxVisibleTags = 4

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(recallQuestion.question)
                .font(.headline)
                .lineLimit(2)

            if let contextText {
                Text(contextText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 6) {
                Text(statusText)
                    .foregroundStyle(statusColor)
                Text("·")
                    .foregroundStyle(.secondary)
                Text(lastReviewedText)
                    .foregroundStyle(.secondary)
            }
            .font(.caption)

            if !recallQuestion.tags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(recallQuestion.tags.prefix(Self.maxVisibleTags), id: \.self) { tag in
                        ActiveRecallRowTagChip(text: tag)
                    }
                    if recallQuestion.tags.count > Self.maxVisibleTags {
                        ActiveRecallRowTagChip(text: "+\(recallQuestion.tags.count - Self.maxVisibleTags)")
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(recallQuestion.question)." +
            (contextText.map { " \($0)." } ?? "") +
            " \(statusText). \(lastReviewedText)." +
            (recallQuestion.tags.isEmpty ? "" : " Tags: \(recallQuestion.tags.joined(separator: ", "))." )
        )
    }
}

/// Compact, read-only tag chip — mirrors `NotesListView.NoteRowTagChip`/
/// `FlashcardListView.FlashcardRowTagChip`.
private struct ActiveRecallRowTagChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .foregroundStyle(Color.accentColor)
            .background(Color.accentColor.opacity(0.15), in: Capsule())
    }
}
