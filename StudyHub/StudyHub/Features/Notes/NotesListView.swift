import SwiftUI

struct NotesListView: View {
    let bookmarkRepository: any BookmarkRepositoryProtocol
    let pdfProgressRepository: any PDFProgressRepositoryProtocol
    let pdfService: any PDFServiceProtocol

    @State private var viewModel: NotesViewModel
    @State private var activeSheet: NoteSheet?
    @State private var filter: NoteFilter = .all
    @State private var sortOrder: NoteSortOrder = .newestCreated
    @State private var searchText: String = ""
    @State private var selectedTag: String?
    @State private var attachmentForViewing: Attachment?
    @State private var noteForPDFViewing: Note?
    @Environment(\.openURL) private var openURL

    init(
        course: Course,
        noteRepository: any NoteRepositoryProtocol,
        bookmarkRepository: any BookmarkRepositoryProtocol,
        pdfProgressRepository: any PDFProgressRepositoryProtocol,
        pdfService: any PDFServiceProtocol
    ) {
        self.bookmarkRepository = bookmarkRepository
        self.pdfProgressRepository = pdfProgressRepository
        self.pdfService = pdfService
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
                        activeSheet = .create
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
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .create:
                NoteFormView(viewModel: viewModel, note: nil, bookmarkRepository: bookmarkRepository, pdfProgressRepository: pdfProgressRepository, pdfService: pdfService)
            case .edit(let note):
                NoteFormView(viewModel: viewModel, note: note, bookmarkRepository: bookmarkRepository, pdfProgressRepository: pdfProgressRepository, pdfService: pdfService)
            }
        }
        .navigationDestination(isPresented: Binding(
            get: { attachmentForViewing != nil },
            set: { isPresented in
                if !isPresented { attachmentForViewing = nil }
            }
        )) {
            if let attachmentForViewing {
                let noteBody = noteForPDFViewing?.body.trimmingCharacters(in: .whitespacesAndNewlines)
                PDFViewerView(
                    attachment: attachmentForViewing,
                    summary: (noteBody?.isEmpty == false) ? noteBody : nil,
                    onSummaryEdit: { newBody in
                        if let noteForPDFViewing {
                            viewModel.updateNote(noteForPDFViewing, title: noteForPDFViewing.title, body: newBody)
                        }
                    },
                    onMarkupSave: { data in
                        viewModel.saveMarkup(data, for: attachmentForViewing)
                    },
                    bookmarkRepository: bookmarkRepository,
                    pdfProgressRepository: pdfProgressRepository,
                    pdfService: pdfService
                )
            }
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
                        Button("Edit", systemImage: "pencil") {
                            activeSheet = .edit(note)
                        }
                        .tint(.blue)
                    }
            }
        }
        .listStyle(.insetGrouped)
    }

    /// Primary row action: opens the note's PDF attachment (if any) directly in
    /// the PDF viewer, opens a Link/GoodNotes attachment via `openURL`, or —
    /// when there's no openable attachment — falls back to the editor exactly
    /// as before. Editing is always still reachable via the "Edit" swipe action.
    private func handleTap(on note: Note) {
        guard let attachment = primaryAttachment(for: note) else {
            activeSheet = .edit(note)
            return
        }

        switch AttachmentKind(rawValue: attachment.type) {
        case .pdf:
            noteForPDFViewing = note
            attachmentForViewing = attachment
        case .link, .goodnotes:
            if let url = URL(string: attachment.url) {
                openURL(url)
            } else {
                activeSheet = .edit(note)
            }
        default:
            activeSheet = .edit(note)
        }
    }

    /// PDF attachments take priority (matching every other opening-behavior
    /// entry point in the app); otherwise the first Link/GoodNotes attachment.
    /// Image/Document/Other attachments have no defined "open" action, so they
    /// don't make a note count as having an openable attachment.
    private func primaryAttachment(for note: Note) -> Attachment? {
        if let pdf = note.attachments.first(where: { AttachmentKind(rawValue: $0.type) == .pdf }) {
            return pdf
        }
        return note.attachments.first {
            let kind = AttachmentKind(rawValue: $0.type)
            return kind == .link || kind == .goodnotes
        }
    }
}

private enum NoteSheet: Identifiable {
    case create
    case edit(Note)

    var id: String {
        switch self {
        case .create: return "create"
        case .edit(let note): return note.id.uuidString
        }
    }
}

private struct NoteRowView: View {
    let note: Note

    private var bodyPreview: String {
        let trimmed = note.body.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "No additional text" : trimmed
    }

    /// The note's single owner (DECISION-031): Lecture name, else Reading
    /// title, else Course name — exactly one is ever set. Falls back to
    /// "Unfiled" for a note whose owner was nullified by a Reading deletion
    /// (DECISION-032).
    private var ownerContext: String {
        if let lecture = note.lecture {
            return lecture.topic
        }
        if let reading = note.reading {
            return reading.title
        }
        if let course = note.course {
            return course.name
        }
        return "Unfiled"
    }

    /// "Created <date>", plus "Edited <date>" only if the edited date differs
    /// from the created date, plus the owner context. See DECISION-030/031.
    private var metadataText: String {
        var parts: [String] = ["Created \(note.createdAt.formatted(date: .abbreviated, time: .omitted))"]

        if !Calendar.current.isDate(note.updatedAt, inSameDayAs: note.createdAt) {
            parts.append("Edited \(note.updatedAt.formatted(date: .abbreviated, time: .omitted))")
        }

        parts.append(ownerContext)

        return parts.joined(separator: " · ")
    }

    /// Full tag text used only for the accessibility label — the visible row
    /// shows compact chips instead (see `body`).
    private var tagsText: String? {
        note.tags.isEmpty ? nil : note.tags.joined(separator: ", ")
    }

    /// Caps visible chips so a heavily-tagged note doesn't blow out row
    /// height; the remainder collapses into a "+N" chip.
    private static let maxVisibleTags = 4

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(note.title.isEmpty ? "Untitled Note" : note.title)
                    .font(.headline)
                Text(bodyPreview)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                Text(metadataText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if !note.tags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(note.tags.prefix(Self.maxVisibleTags), id: \.self) { tag in
                            NoteRowTagChip(text: tag)
                        }
                        if note.tags.count > Self.maxVisibleTags {
                            NoteRowTagChip(text: "+\(note.tags.count - Self.maxVisibleTags)")
                        }
                    }
                }
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
            "\(note.title.isEmpty ? "Untitled Note" : note.title). \(bodyPreview). \(metadataText)." +
            (tagsText.map { " Tags: \($0)." } ?? "") +
            (note.attachments.isEmpty ? "" : " Has attachments.")
        )
    }
}

/// Compact, read-only tag chip for a Notes row — no tap/remove affordance,
/// unlike NoteFormView's editable `NoteTagChip`.
private struct NoteRowTagChip: View {
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
