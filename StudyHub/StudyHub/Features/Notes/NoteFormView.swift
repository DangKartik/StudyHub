import SwiftUI

struct NoteFormView: View {
    let viewModel: NotesViewModel
    let note: Note?

    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var noteBody: String = ""
    @State private var isAddingAttachment = false

    private var isEditing: Bool {
        note != nil
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("Title", text: $title)
                }

                Section("Note") {
                    TextEditor(text: $noteBody)
                        .frame(minHeight: 150)
                }

                attachmentsSection
            }
            .navigationTitle(isEditing ? "Edit Note" : "New Note")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let note {
                            viewModel.updateNote(note, title: title, body: noteBody)
                        } else {
                            viewModel.createNote(title: title, body: noteBody)
                        }
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
            .sheet(isPresented: $isAddingAttachment) {
                if let note {
                    AttachmentFormView(viewModel: viewModel, note: note)
                }
            }
            .onAppear {
                if let note {
                    title = note.title
                    noteBody = note.body
                }
            }
        }
    }

    @ViewBuilder
    private var attachmentsSection: some View {
        if let note {
            Section("Attachments") {
                if note.attachments.isEmpty {
                    Text("No attachments yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(note.attachments.sorted { $0.createdAt < $1.createdAt }, id: \.id) { attachment in
                        AttachmentRowView(attachment: attachment)
                            .swipeActions(edge: .trailing) {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    viewModel.deleteAttachment(attachment)
                                }
                            }
                    }
                }

                Button {
                    isAddingAttachment = true
                } label: {
                    Label("Add Attachment", systemImage: "paperclip")
                }
            }
        } else {
            Section("Attachments") {
                Text("Save this note first to add attachments.")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct AttachmentRowView: View {
    let attachment: Attachment

    var body: some View {
        HStack {
            Image(systemName: AttachmentKind(rawValue: attachment.type)?.icon ?? "doc")
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text(attachment.filename)
                Text(AttachmentKind(rawValue: attachment.type)?.label ?? attachment.type)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(attachment.filename), \(AttachmentKind(rawValue: attachment.type)?.label ?? attachment.type)")
    }
}

private enum AttachmentKind: String, CaseIterable {
    case pdf
    case image
    case document
    case goodnotes
    case link
    case other

    var label: String {
        switch self {
        case .pdf: return "PDF"
        case .image: return "Image"
        case .document: return "Document"
        case .goodnotes: return "GoodNotes"
        case .link: return "Link"
        case .other: return "Other"
        }
    }

    var icon: String {
        switch self {
        case .pdf: return "doc.richtext"
        case .image: return "photo"
        case .document: return "doc.text"
        case .goodnotes: return "pencil.and.outline"
        case .link: return "link"
        case .other: return "paperclip"
        }
    }
}

private struct AttachmentFormView: View {
    let viewModel: NotesViewModel
    let note: Note

    @Environment(\.dismiss) private var dismiss

    @State private var filename: String = ""
    @State private var kind: AttachmentKind = .document
    @State private var url: String = ""

    private var canSave: Bool {
        !filename.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Filename") {
                    TextField("Filename", text: $filename)
                }

                Section("Type") {
                    Picker("Type", selection: $kind) {
                        ForEach(AttachmentKind.allCases, id: \.self) { attachmentKind in
                            Text(attachmentKind.label).tag(attachmentKind)
                        }
                    }
                }

                Section("Reference") {
                    TextField("URL or file reference", text: $url)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
            }
            .navigationTitle("Add Attachment")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        viewModel.addAttachment(to: note, filename: filename, type: kind.rawValue, url: url)
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
}
