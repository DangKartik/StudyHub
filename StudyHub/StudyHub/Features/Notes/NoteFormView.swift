import SwiftUI
import UniformTypeIdentifiers

struct NoteFormView: View {
    let viewModel: NotesViewModel
    let note: Note?
    let pdfService: any PDFServiceProtocol

    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var noteBody: String = ""
    @State private var selectedLecture: Lecture?
    @State private var pendingAttachments: [Attachment] = []
    @State private var isAddingAttachment = false
    @State private var attachmentForViewing: Attachment?
    @State private var attachmentError: StudyHubError?
    @State private var didSaveNote = false

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

                if !isEditing && viewModel.isCourseScope {
                    Section("Attach To") {
                        Picker("Lecture", selection: $selectedLecture) {
                            Text("Course Only").tag(nil as Lecture?)
                            ForEach(viewModel.availableLectures, id: \.id) { lecture in
                                Text(lecture.topic).tag(Optional(lecture))
                            }
                        }
                    }
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
                            didSaveNote = true
                            viewModel.createNote(
                                title: title,
                                body: noteBody,
                                lecture: selectedLecture,
                                attachments: pendingAttachments
                            )
                        }
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
            .sheet(isPresented: $isAddingAttachment) {
                // AttachmentFormView always stages PDFs to temporary storage and
                // never finalizes them itself — the caller decides when a file
                // actually becomes permanent, since that depends on whether this
                // Note is already saved (see Part 3 / DECISION-029 successor logic
                // below) or still being composed.
                AttachmentFormView { filename, type, tempOrURLValue in
                    if let note {
                        commitAttachment(to: note, filename: filename, type: type, value: tempOrURLValue)
                    } else {
                        pendingAttachments.append(Attachment(filename: filename, type: type, url: tempOrURLValue))
                    }
                }
            }
            .navigationDestination(isPresented: Binding(
                get: { attachmentForViewing != nil },
                set: { isPresented in
                    if !isPresented { attachmentForViewing = nil }
                }
            )) {
                if let attachmentForViewing {
                    PDFViewerView(attachment: attachmentForViewing, pdfService: pdfService)
                }
            }
            .alert(
                attachmentError?.title ?? "Attachment Error",
                isPresented: Binding(
                    get: { attachmentError != nil },
                    set: { isPresented in
                        if !isPresented { attachmentError = nil }
                    }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(attachmentError?.message ?? "This attachment could not be saved.")
            }
            .onAppear {
                if let note {
                    title = note.title
                    noteBody = note.body
                }
            }
            .onDisappear {
                if !didSaveNote {
                    discardPendingAttachments()
                }
            }
        }
    }

    /// Editing an existing, already-persisted Note: the attachment is being
    /// committed right now, not staged for a later Save. A staged PDF's value
    /// is a temporary path that needs finalizing into permanent storage first;
    /// every other kind is already a plain reference string with nothing to move.
    private func commitAttachment(to note: Note, filename: String, type: String, value: String) {
        guard type == AttachmentKind.pdf.rawValue else {
            viewModel.addAttachment(to: note, filename: filename, type: type, url: value)
            return
        }

        do {
            let finalPath = try AttachmentFileImporter.finalize(temporaryPath: value)
            viewModel.addAttachment(to: note, filename: filename, type: type, url: finalPath)
        } catch let error as StudyHubError {
            attachmentError = error
        } catch {
            attachmentError = AttachmentImportError.copyFailed
        }
    }

    /// Deletes the temporary files backing any staged-but-never-saved PDF
    /// attachments — called when this form disappears without the note having
    /// been saved (Cancel, swipe-to-dismiss, or any other dismissal path).
    private func discardPendingAttachments() {
        for attachment in pendingAttachments where attachment.type == AttachmentKind.pdf.rawValue {
            AttachmentFileImporter.deleteTemporaryFile(at: attachment.url)
        }
    }

    @ViewBuilder
    private var attachmentsSection: some View {
        Section("Attachments") {
            if let note {
                if note.attachments.isEmpty {
                    Text("No attachments yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(note.attachments.sorted { $0.createdAt < $1.createdAt }, id: \.id) { attachment in
                        attachmentRow(attachment) {
                            viewModel.deleteAttachment(attachment)
                        }
                    }
                }
            } else {
                if pendingAttachments.isEmpty {
                    Text("No attachments yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(pendingAttachments, id: \.id) { attachment in
                        attachmentRow(attachment) {
                            if attachment.type == AttachmentKind.pdf.rawValue {
                                AttachmentFileImporter.deleteTemporaryFile(at: attachment.url)
                            }
                            pendingAttachments.removeAll { $0.id == attachment.id }
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
    }

    @ViewBuilder
    private func attachmentRow(_ attachment: Attachment, onDelete: @escaping () -> Void) -> some View {
        AttachmentRowView(attachment: attachment)
            .contentShape(Rectangle())
            .onTapGesture {
                if AttachmentKind(rawValue: attachment.type) == .pdf {
                    attachmentForViewing = attachment
                }
            }
            .swipeActions(edge: .trailing) {
                Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
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

enum AttachmentKind: String, CaseIterable {
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
    /// Called with (filename, type rawValue, value) when the user taps Add.
    /// For `.pdf`, `value` is a *temporary* staged file path, not yet
    /// permanent — the caller decides when (or whether) to finalize it. Every
    /// other kind's `value` is already the final reference string.
    let onAdd: (String, String, String) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var filename: String = ""
    @State private var kind: AttachmentKind = .pdf
    @State private var url: String = ""
    @State private var temporaryPath: String?
    @State private var isImportingFile = false
    @State private var importError: StudyHubError?
    @State private var didCommit = false

    private var canSave: Bool {
        !filename.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (kind != .pdf || temporaryPath != nil)
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

                if kind == .pdf {
                    Section("File") {
                        Button {
                            isImportingFile = true
                        } label: {
                            Label(temporaryPath == nil ? "Import PDF" : "Replace PDF", systemImage: "square.and.arrow.down")
                        }
                        if temporaryPath != nil {
                            Label("File imported", systemImage: "checkmark.circle")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } else {
                    Section("Reference") {
                        TextField("URL or file reference", text: $url)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
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
                        didCommit = true
                        onAdd(filename, kind.rawValue, kind == .pdf ? (temporaryPath ?? "") : url)
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
            .fileImporter(isPresented: $isImportingFile, allowedContentTypes: [.pdf]) { result in
                switch result {
                case .success(let pickedURL):
                    do {
                        let imported = try AttachmentFileImporter.importToTemporaryStorage(from: pickedURL)
                        if let previousTemporaryPath = temporaryPath {
                            AttachmentFileImporter.deleteTemporaryFile(at: previousTemporaryPath)
                        }
                        temporaryPath = imported.path
                        filename = imported.filename
                    } catch let error as StudyHubError {
                        importError = error
                    } catch {
                        importError = AttachmentImportError.copyFailed
                    }
                case .failure:
                    importError = AttachmentImportError.copyFailed
                }
            }
            .alert(
                importError?.title ?? "Import Failed",
                isPresented: Binding(
                    get: { importError != nil },
                    set: { isPresented in
                        if !isPresented { importError = nil }
                    }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(importError?.message ?? "This file could not be imported.")
            }
            .onDisappear {
                if !didCommit, let temporaryPath {
                    AttachmentFileImporter.deleteTemporaryFile(at: temporaryPath)
                }
            }
        }
    }
}
