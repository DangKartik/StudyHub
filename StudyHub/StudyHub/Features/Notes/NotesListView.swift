import SwiftUI

struct NotesListView: View {
    let pdfService: any PDFServiceProtocol

    @State private var viewModel: NotesViewModel
    @State private var activeSheet: NoteSheet?
    @State private var filter: NoteFilter = .all
    @State private var sortOrder: NoteSortOrder = .newestCreated
    @State private var attachmentForViewing: Attachment?
    @State private var noteForPDFViewing: Note?
    @Environment(\.openURL) private var openURL

    init(course: Course, noteRepository: any NoteRepositoryProtocol, pdfService: any PDFServiceProtocol) {
        self.pdfService = pdfService
        _viewModel = State(wrappedValue: NotesViewModel(
            scope: .course(course),
            noteRepository: noteRepository
        ))
    }

    init(lecture: Lecture, noteRepository: any NoteRepositoryProtocol, pdfService: any PDFServiceProtocol) {
        self.pdfService = pdfService
        _viewModel = State(wrappedValue: NotesViewModel(
            scope: .lecture(lecture),
            noteRepository: noteRepository
        ))
    }

    private var displayedNotes: [Note] {
        viewModel.displayedNotes(filter: filter, sortOrder: sortOrder)
    }

    var body: some View {
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
        .navigationTitle("Notes")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    activeSheet = .create
                } label: {
                    Label("Add Note", systemImage: "plus")
                }
            }
            ToolbarItem(placement: .secondaryAction) {
                Menu {
                    Picker("Filter", selection: $filter) {
                        ForEach(NoteFilter.allCases) { filterOption in
                            Text(filterOption.label).tag(filterOption)
                        }
                    }
                    Picker("Sort", selection: $sortOrder) {
                        ForEach(NoteSortOrder.allCases) { sortOption in
                            Text(sortOption.label).tag(sortOption)
                        }
                    }
                } label: {
                    Label("Filter & Sort", systemImage: "line.3.horizontal.decrease.circle")
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .create:
                NoteFormView(viewModel: viewModel, note: nil, pdfService: pdfService)
            case .edit(let note):
                NoteFormView(viewModel: viewModel, note: note, pdfService: pdfService)
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
                    pdfService: pdfService
                )
            }
        }
        .onAppear {
            viewModel.loadNotes()
        }
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

    /// "Created <date>", plus "Edited <date>" only if the edited date differs
    /// from the created date, plus an ownership indicator — either "Course
    /// Note" or the owning Lecture's name. See DECISION-030.
    private var metadataText: String {
        var parts: [String] = ["Created \(note.createdAt.formatted(date: .abbreviated, time: .omitted))"]

        if !Calendar.current.isDate(note.updatedAt, inSameDayAs: note.createdAt) {
            parts.append("Edited \(note.updatedAt.formatted(date: .abbreviated, time: .omitted))")
        }

        if let lecture = note.lecture {
            parts.append(lecture.topic)
        } else {
            parts.append("Course Note")
        }

        return parts.joined(separator: " · ")
    }

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
            (note.attachments.isEmpty ? "" : " Has attachments.")
        )
    }
}
