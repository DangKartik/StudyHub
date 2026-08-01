import SwiftUI

struct NotesListView: View {
    let bookmarkRepository: any BookmarkRepositoryProtocol
    let pdfProgressRepository: any PDFProgressRepositoryProtocol
    let pdfService: any PDFServiceProtocol
    /// Phase 4.3 (Study Mode) — invoked once per note opened (any of PDF /
    /// URL / edit sheet), so an embedding Study Session can tally "Notes
    /// opened" live without this view needing to know Study Mode exists.
    /// `nil` everywhere else, so every existing call site is unaffected.
    var onNoteOpened: (() -> Void)? = nil

    @State private var viewModel: NotesViewModel
    @State private var isCreatingNote = false
    @State private var filter: NoteFilter = .all
    @State private var sortOrder: NoteSortOrder = .newestCreated
    @State private var searchText: String = ""
    @State private var selectedTag: String?
    @State private var noteForDetail: Note?

    init(
        course: Course,
        noteRepository: any NoteRepositoryProtocol,
        bookmarkRepository: any BookmarkRepositoryProtocol,
        pdfProgressRepository: any PDFProgressRepositoryProtocol,
        pdfService: any PDFServiceProtocol,
        onNoteOpened: (() -> Void)? = nil
    ) {
        self.bookmarkRepository = bookmarkRepository
        self.pdfProgressRepository = pdfProgressRepository
        self.pdfService = pdfService
        self.onNoteOpened = onNoteOpened
        _viewModel = State(wrappedValue: NotesViewModel(
            scope: .course(course),
            noteRepository: noteRepository
        ))
    }

    init(
        lecture: Lecture,
        noteRepository: any NoteRepositoryProtocol,
        bookmarkRepository: any BookmarkRepositoryProtocol,
        pdfProgressRepository: any PDFProgressRepositoryProtocol,
        pdfService: any PDFServiceProtocol
    ) {
        self.bookmarkRepository = bookmarkRepository
        self.pdfProgressRepository = pdfProgressRepository
        self.pdfService = pdfService
        _viewModel = State(wrappedValue: NotesViewModel(
            scope: .lecture(lecture),
            noteRepository: noteRepository
        ))
    }

    /// Cross-course "All Notes" browsing (Phase 3.1) — no Course/Lecture
    /// scope, backed by `NotesViewModel.Scope.global`. See DECISION-031.
    init(
        noteRepository: any NoteRepositoryProtocol,
        bookmarkRepository: any BookmarkRepositoryProtocol,
        pdfProgressRepository: any PDFProgressRepositoryProtocol,
        pdfService: any PDFServiceProtocol
    ) {
        self.bookmarkRepository = bookmarkRepository
        self.pdfProgressRepository = pdfProgressRepository
        self.pdfService = pdfService
        _viewModel = State(wrappedValue: NotesViewModel(
            scope: .global,
            noteRepository: noteRepository
        ))
    }

    private var displayedNotes: [Note] {
        viewModel.displayedNotes(filter: filter, sortOrder: sortOrder, searchText: searchText, tag: selectedTag)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            Group {
                if viewModel.notes.isEmpty {
                    StudyHubEmptyState(
                        icon: "note.text",
                        title: "No Notes Yet",
                        message: "Add a note to keep track of what matters."
                    )
                } else if displayedNotes.isEmpty {
                    StudyHubEmptyState(
                        icon: "line.3.horizontal.decrease.circle",
                        title: "No Matching Notes",
                        message: "Try a different filter."
                    )
                } else {
                    list
                }
            }
        }
        .navigationTitle("Notes")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search Notes")
        .toolbar {
            if viewModel.supportsCreation {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isCreatingNote = true
                    } label: {
                        Label("Add Note", systemImage: "plus")
                    }
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Picker("Filter", selection: $filter) {
                        ForEach(NoteFilter.allCases) { filterOption in
                            Text(filterOption.label).tag(filterOption)
                        }
                    }
                    .pickerStyle(.inline)
                    if !viewModel.allTags.isEmpty {
                        // Deliberately not .pickerStyle(.inline) — Tag stays a
                        // nested "Tag ›" submenu, unlike Filter/Sort above.
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
        .fullScreenCover(isPresented: $isCreatingNote) {
            NoteBodyEditorView(note: nil, viewModel: viewModel)
        }
        .fullScreenCover(item: $noteForDetail) { note in
            NoteDetailView(
                note: note,
                viewModel: viewModel,
                bookmarkRepository: bookmarkRepository,
                pdfProgressRepository: pdfProgressRepository,
                pdfService: pdfService
            )
        }
        .onAppear {
            viewModel.loadNotes()
        }
    }

    /// Custom title row — replaces the system large title (suppressed via
    /// .navigationBarTitleDisplayMode(.inline)) so Sort can sit on the same
    /// line as "Notes" instead of in the toolbar.
    private var header: some View {
        HStack {
            Text("Notes")
                .font(.largeTitle)
                .fontWeight(.bold)

            Spacer()

            Menu {
                Picker("Sort", selection: $sortOrder) {
                    ForEach(NoteSortOrder.allCases) { sortOption in
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

            ForEach(displayedNotes, id: \.id) { note in
                NoteRowView(note: note)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        handleTap(on: note)
                    }
                    .accessibilityAddTraits(.isButton)
                    .swipeActions(edge: .trailing) {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            viewModel.deleteNote(note)
                        }
                    }
            }
        }
        .listStyle(.insetGrouped)
    }

    /// Primary row action: opens the full-screen read-only preview
    /// (`NoteDetailView`) — title, tags, and rendered body. Editing (title,
    /// tags, body, attachments) is only reachable from there via "Edit"
    /// (`NoteBodyEditorView`) — there's no separate swipe-to-edit shortcut
    /// anymore, so there's exactly one editing entry point instead of two
    /// with different scopes.
    private func handleTap(on note: Note) {
        onNoteOpened?()
        noteForDetail = note
    }
}

private struct NoteRowView: View {
    let note: Note

    /// "Edited <date>" once actually edited, else "Created <date>" — never
    /// both, matching `NoteDetailView`'s header exactly.
    private var dateText: String {
        if note.hasBeenEdited {
            return "Edited \(note.updatedAt.formatted(date: .abbreviated, time: .omitted))"
        }
        return "Created \(note.createdAt.formatted(date: .abbreviated, time: .omitted))"
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(note.title.isEmpty ? "Untitled Note" : note.title)
                    .font(.headline)
                if note.hasOwner {
                    Text(note.ownerContextLabel)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Text(dateText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if !note.attachments.isEmpty {
                Image(systemName: "paperclip")
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Has attachments")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(note.title.isEmpty ? "Untitled Note" : note.title). " +
            (note.hasOwner ? "\(note.ownerContextLabel). " : "") +
            "\(dateText)." +
            (note.attachments.isEmpty ? "" : " Has attachments.")
        )
    }
}
