import SwiftUI

struct NotesListView: View {
    @State private var viewModel: NotesViewModel
    @State private var activeSheet: NoteSheet?

    init(course: Course, noteRepository: any NoteRepositoryProtocol) {
        _viewModel = State(wrappedValue: NotesViewModel(
            scope: .course(course),
            noteRepository: noteRepository
        ))
    }

    init(lecture: Lecture, noteRepository: any NoteRepositoryProtocol) {
        _viewModel = State(wrappedValue: NotesViewModel(
            scope: .lecture(lecture),
            noteRepository: noteRepository
        ))
    }

    var body: some View {
        Group {
            if viewModel.notes.isEmpty {
                StudyHubEmptyState(
                    icon: "note.text",
                    title: "No Notes Yet",
                    message: "Add a note to keep track of what matters."
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
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .create:
                NoteFormView(viewModel: viewModel, note: nil)
            case .edit(let note):
                NoteFormView(viewModel: viewModel, note: note)
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

            ForEach(viewModel.notes, id: \.id) { note in
                NoteRowView(note: note)
                    .onTapGesture {
                        activeSheet = .edit(note)
                    }
                    .swipeActions(edge: .trailing) {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            viewModel.deleteNote(note)
                        }
                    }
            }
        }
        .listStyle(.insetGrouped)
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

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(note.title.isEmpty ? "Untitled Note" : note.title)
                    .font(.headline)
                Text(bodyPreview)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
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
            "\(note.title.isEmpty ? "Untitled Note" : note.title). \(bodyPreview)." +
            (note.attachments.isEmpty ? "" : " Has attachments.")
        )
    }
}
