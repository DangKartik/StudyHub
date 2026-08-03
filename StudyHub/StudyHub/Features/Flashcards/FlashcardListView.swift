import SwiftUI

struct FlashcardListView: View {
    let flashcardRepository: any FlashcardRepositoryProtocol
    let lectureRepository: any LectureRepositoryProtocol
    let noteRepository: any NoteRepositoryProtocol
    let bookmarkRepository: any BookmarkRepositoryProtocol
    let pdfProgressRepository: any PDFProgressRepositoryProtocol
    let pdfService: any PDFServiceProtocol
    /// Phase 4.3 (Study Mode) — invoked once per card rating, so an
    /// embedding Study Session can tally "Flashcards reviewed" live. `nil`
    /// everywhere else, zero effect on any existing call site.
    var onCardReviewed: (() -> Void)? = nil

    @State private var viewModel: FlashcardsViewModel
    @State private var activeSheet: FlashcardSheet?
    @State private var reviewSession: FlashcardReviewSession?
    @State private var lectureForViewing: Lecture?
    @State private var noteForViewing: Note?
    @State private var sortOrder: FlashcardSortOrder = .newestCreated
    @State private var searchText: String = ""
    @State private var selectedTag: String?
    @State private var selectedCourse: Course?
    @State private var ratingFilter: FlashcardRatingFilter = .all

    private let isGlobal: Bool

    init(
        course: Course,
        noteRepository: any NoteRepositoryProtocol,
        lectureRepository: any LectureRepositoryProtocol,
        flashcardRepository: any FlashcardRepositoryProtocol,
        bookmarkRepository: any BookmarkRepositoryProtocol,
        pdfProgressRepository: any PDFProgressRepositoryProtocol,
        pdfService: any PDFServiceProtocol,
        onCardReviewed: (() -> Void)? = nil
    ) {
        self.flashcardRepository = flashcardRepository
        self.lectureRepository = lectureRepository
        self.noteRepository = noteRepository
        self.bookmarkRepository = bookmarkRepository
        self.pdfProgressRepository = pdfProgressRepository
        self.pdfService = pdfService
        self.onCardReviewed = onCardReviewed
        self.isGlobal = false
        _viewModel = State(wrappedValue: FlashcardsViewModel(
            scope: .course(course),
            flashcardRepository: flashcardRepository,
            noteRepository: noteRepository
        ))
    }

    init(
        lecture: Lecture,
        noteRepository: any NoteRepositoryProtocol,
        lectureRepository: any LectureRepositoryProtocol,
        flashcardRepository: any FlashcardRepositoryProtocol,
        bookmarkRepository: any BookmarkRepositoryProtocol,
        pdfProgressRepository: any PDFProgressRepositoryProtocol,
        pdfService: any PDFServiceProtocol
    ) {
        self.flashcardRepository = flashcardRepository
        self.lectureRepository = lectureRepository
        self.noteRepository = noteRepository
        self.bookmarkRepository = bookmarkRepository
        self.pdfProgressRepository = pdfProgressRepository
        self.pdfService = pdfService
        self.isGlobal = false
        _viewModel = State(wrappedValue: FlashcardsViewModel(
            scope: .lecture(lecture),
            flashcardRepository: flashcardRepository,
            noteRepository: noteRepository
        ))
    }

    /// Cross-course "All Flashcards" browsing (Phase 4.1) — no Course/Lecture
    /// scope, backed by `FlashcardsViewModel.Scope.global`. Mirrors
    /// `NotesListView`'s equivalent global initializer (DECISION-031).
    init(
        noteRepository: any NoteRepositoryProtocol,
        lectureRepository: any LectureRepositoryProtocol,
        flashcardRepository: any FlashcardRepositoryProtocol,
        bookmarkRepository: any BookmarkRepositoryProtocol,
        pdfProgressRepository: any PDFProgressRepositoryProtocol,
        pdfService: any PDFServiceProtocol
    ) {
        self.flashcardRepository = flashcardRepository
        self.lectureRepository = lectureRepository
        self.noteRepository = noteRepository
        self.bookmarkRepository = bookmarkRepository
        self.pdfProgressRepository = pdfProgressRepository
        self.pdfService = pdfService
        self.isGlobal = true
        _viewModel = State(wrappedValue: FlashcardsViewModel(
            scope: .global,
            flashcardRepository: flashcardRepository,
            noteRepository: noteRepository
        ))
    }

    private var displayedFlashcards: [Flashcard] {
        viewModel.displayedFlashcards(
            searchText: searchText,
            tag: selectedTag,
            course: selectedCourse,
            ratingFilter: ratingFilter,
            sortOrder: sortOrder
        )
    }

    /// Phase 4.4 (requirement 3/6) — the subset of `displayedFlashcards`
    /// actually due for review right now (due today or never reviewed).
    /// Drives the bulk "Review" button's default instead of reviewing
    /// every card; tapping an individual row still reviews that one card
    /// regardless of due status.
    private var dueFlashcards: [Flashcard] {
        viewModel.dueFlashcards(from: displayedFlashcards)
    }

    /// Reviewing early is never harmful, just not schedule-optimal — so
    /// the bulk button only disables entirely when there's truly nothing
    /// to review, falling back to every card instead of staying stuck on
    /// "0 due" when the student wants to study ahead of schedule anyway.
    private var reviewButtonCards: [Flashcard] {
        dueFlashcards.isEmpty ? displayedFlashcards : dueFlashcards
    }

    private var reviewButtonLabel: String {
        if !dueFlashcards.isEmpty {
            return "Review \(dueFlashcards.count) Due Card\(dueFlashcards.count == 1 ? "" : "s")"
        } else if !displayedFlashcards.isEmpty {
            return "Study Ahead (\(displayedFlashcards.count) Card\(displayedFlashcards.count == 1 ? "" : "s"))"
        } else {
            return "No Cards to Review"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            Group {
                if viewModel.flashcards.isEmpty {
                    StudyHubEmptyState(
                        icon: "rectangle.stack",
                        title: "No Flashcards Yet",
                        message: "Add flashcards to help you review this material.",
                        actionTitle: viewModel.supportsCreation ? "Add Flashcard" : nil
                    ) {
                        activeSheet = .create
                    }
                } else if displayedFlashcards.isEmpty {
                    StudyHubEmptyState(
                        icon: "line.3.horizontal.decrease.circle",
                        title: "No Matching Flashcards",
                        message: "Try a different filter."
                    )
                } else {
                    list
                }
            }
        }
        .navigationTitle("Flashcards")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search Flashcards")
        .toolbar {
            if viewModel.supportsCreation {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        activeSheet = .create
                    } label: {
                        Label("Add Flashcard", systemImage: "plus")
                    }
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    if isGlobal, !viewModel.allCourses.isEmpty {
                        // Not .pickerStyle(.inline) — stays a nested "Course
                        // ›" submenu, same convention as Tag below.
                        Picker("Course", selection: $selectedCourse) {
                            Text("All Courses").tag(Course?.none)
                            ForEach(viewModel.allCourses, id: \.id) { course in
                                Text(course.name).tag(Course?.some(course))
                            }
                        }
                    }
                    if !viewModel.allTags.isEmpty {
                        Picker("Tag", selection: $selectedTag) {
                            Text("All Tags").tag(String?.none)
                            ForEach(viewModel.allTags, id: \.self) { tag in
                                Text(tag).tag(String?.some(tag))
                            }
                        }
                    }
                    Picker("Status", selection: $ratingFilter) {
                        ForEach(FlashcardRatingFilter.allCases) { option in
                            Text(option.label).tag(option)
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
                FlashcardFormView(viewModel: viewModel, flashcard: nil)
            case .edit(let flashcard):
                FlashcardFormView(viewModel: viewModel, flashcard: flashcard)
            }
        }
        // .fullScreenCover(item:), not (isPresented:) + a separately-mutated
        // array — that combination is a well-known SwiftUI trap: the cover's
        // content view's own @State (FlashcardReviewViewModel) only
        // initializes from its `cards` argument the very first time this
        // call site's content closure builds a view, and doesn't reset on
        // later presentations at the same site, since the view's identity
        // doesn't change just because `isPresented` toggles. That's exactly
        // why every review session was showing "Review Complete — 0 cards":
        // it kept reusing the *first* session's already-finished state.
        // Giving each session a fresh Identifiable id forces a genuinely new
        // view identity — and therefore fresh @State — every time.
        .fullScreenCover(item: $reviewSession) { session in
            FlashcardReviewView(cards: session.cards, flashcardRepository: flashcardRepository, onRate: onCardReviewed)
        }
        .sheet(item: $lectureForViewing) { lecture in
            if let course = lecture.course {
                LectureFormView(
                    viewModel: LectureViewModel(course: course, lectureRepository: lectureRepository),
                    lecture: lecture,
                    bookmarkRepository: bookmarkRepository,
                    pdfProgressRepository: pdfProgressRepository,
                    pdfService: pdfService
                )
            }
        }
        .sheet(item: $noteForViewing) { note in
            NoteFormView(
                viewModel: NotesViewModel(scope: .global, noteRepository: noteRepository),
                note: note,
                bookmarkRepository: bookmarkRepository,
                pdfProgressRepository: pdfProgressRepository,
                pdfService: pdfService
            )
        }
        .onAppear {
            viewModel.loadFlashcards()
        }
    }

    /// Custom title row — matches NotesListView's pattern (Sort on the same
    /// line as the title, system large title suppressed).
    private var header: some View {
        HStack {
            Text("Flashcards")
                .font(.largeTitle)
                .fontWeight(.bold)

            Spacer()

            Menu {
                Picker("Sort", selection: $sortOrder) {
                    ForEach(FlashcardSortOrder.allCases) { sortOption in
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
                    reviewSession = FlashcardReviewSession(cards: reviewButtonCards)
                } label: {
                    Label(reviewButtonLabel, systemImage: "shuffle")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .padding()
                .disabled(reviewButtonCards.isEmpty)
            }

            // Review Queue (Phase 4.4): grouped by the shared SM-2 due-date
            // schedule (Due Today/Due Soon/Future/Never Reviewed), same
            // grouping Active Recall uses.
            ForEach(viewModel.queueSections(from: displayedFlashcards), id: \.section) { group in
                Section(group.section.title) {
                    ForEach(group.flashcards, id: \.id) { flashcard in
                        FlashcardRowView(
                            flashcard: flashcard,
                            onViewLecture: { lectureForViewing = flashcard.lecture },
                            onViewNote: { noteForViewing = flashcard.note }
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            reviewSession = FlashcardReviewSession(cards: [flashcard])
                        }
                        .accessibilityAddTraits(.isButton)
                        .swipeActions(edge: .trailing) {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                viewModel.deleteFlashcard(flashcard)
                            }
                            Button("Edit", systemImage: "pencil") {
                                activeSheet = .edit(flashcard)
                            }
                            .tint(.blue)
                        }
                        .contextMenu {
                            Button("Edit", systemImage: "pencil") {
                                activeSheet = .edit(flashcard)
                            }
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                viewModel.deleteFlashcard(flashcard)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

private enum FlashcardSheet: Identifiable {
    case create
    case edit(Flashcard)

    var id: String {
        switch self {
        case .create: return "create"
        case .edit(let flashcard): return flashcard.id.uuidString
        }
    }
}

/// A fresh identity per review pass (see the `.fullScreenCover(item:)`
/// comment in `body`) — the `id` only needs to be unique per session, it's
/// never looked up again.
private struct FlashcardReviewSession: Identifiable {
    let id = UUID()
    let cards: [Flashcard]
}

private struct FlashcardRowView: View {
    let flashcard: Flashcard
    let onViewLecture: () -> Void
    let onViewNote: () -> Void

    private var lectureText: String? {
        flashcard.lecture?.topic
    }

    private var noteText: String? {
        let title = flashcard.note?.title
        guard let title, !title.isEmpty else { return flashcard.note != nil ? "Untitled Note" : nil }
        return title
    }

    private static let maxVisibleTags = 4

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(flashcard.front)
                    .font(.headline)
                    .lineLimit(2)

                if let lectureText {
                    Text(lectureText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if !flashcard.tags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(flashcard.tags.prefix(Self.maxVisibleTags), id: \.self) { tag in
                            FlashcardRowTagChip(text: tag)
                        }
                        if flashcard.tags.count > Self.maxVisibleTags {
                            FlashcardRowTagChip(text: "+\(flashcard.tags.count - Self.maxVisibleTags)")
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Explicit view actions, separate from the row's own tap
            // (which starts a review) — a Button intercepts its own taps
            // before the row's .onTapGesture sees them, so these don't
            // accidentally launch a review instead.
            VStack(alignment: .trailing, spacing: 6) {
                if flashcard.lecture != nil {
                    Button(action: onViewLecture) {
                        Label("Lecture", systemImage: "book.closed")
                    }
                }
                if flashcard.note != nil {
                    Button(action: onViewNote) {
                        Label("Note", systemImage: "note.text")
                    }
                }
            }
            .font(.caption)
            .buttonStyle(.bordered)
            .controlSize(.mini)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(flashcard.front)." +
            (lectureText.map { " Lecture: \($0)." } ?? "") +
            (noteText.map { " Linked note: \($0)." } ?? "") +
            (flashcard.tags.isEmpty ? "" : " Tags: \(flashcard.tags.joined(separator: ", "))." )
        )
    }
}

/// Compact, read-only tag chip for a Flashcard row — mirrors
/// `NotesListView.NoteRowTagChip`.
private struct FlashcardRowTagChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, StudyHubMetrics.chipHorizontalPadding)
            .padding(.vertical, StudyHubMetrics.chipVerticalPadding)
            .foregroundStyle(Color.accentColor)
            .background(Color.accentColor.opacity(0.15), in: Capsule())
    }
}
