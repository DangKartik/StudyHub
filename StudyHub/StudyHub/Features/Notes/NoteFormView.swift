import SwiftUI
import UniformTypeIdentifiers

struct NoteFormView: View {
    let viewModel: NotesViewModel
    let note: Note?
    let bookmarkRepository: any BookmarkRepositoryProtocol
    let pdfProgressRepository: any PDFProgressRepositoryProtocol
    let pdfService: any PDFServiceProtocol

    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var noteBody: String = ""
    @State private var contentMode: ContentMode = .edit
    @State private var markdownEditorController = NoteMarkdownEditorController()
    @State private var tags: [String] = []
    @State private var newTagText: String = ""
    @State private var selectedLecture: Lecture?
    @State private var pendingAttachments: [Attachment] = []
    @State private var isAddingAttachment = false
    @State private var attachmentForViewing: Attachment?
    @State private var attachmentError: StudyHubError?
    @State private var didSaveNote = false

    private enum ContentMode: Hashable {
        case edit
        case preview
    }

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
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.vertical, 4)
                }

                contentSection

                tagsSection

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
                            viewModel.updateNote(note, title: title, body: noteBody, tags: tags)
                        } else {
                            didSaveNote = true
                            viewModel.createNote(
                                title: title,
                                body: noteBody,
                                lecture: selectedLecture,
                                tags: tags,
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
                    let noteBody = note?.body.trimmingCharacters(in: .whitespacesAndNewlines)
                    PDFViewerView(
                        attachment: attachmentForViewing,
                        summary: (noteBody?.isEmpty == false) ? noteBody : nil,
                        onSummaryEdit: { newBody in
                            if let note {
                                viewModel.updateNote(note, title: note.title, body: newBody)
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
                    tags = note.tags
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

    /// Replaces the old plain TextEditor with a Markdown-formatted editor
    /// (headings/bold/italic/lists/checklists/code blocks) plus an
    /// Edit/Preview toggle — see DECISION-033 for why formatting is stored
    /// as Markdown text in `body: String` rather than rich-text data.
    @ViewBuilder
    private var contentSection: some View {
        Section("Content") {
            Picker("Mode", selection: $contentMode) {
                Text("Edit").tag(ContentMode.edit)
                Text("Preview").tag(ContentMode.preview)
            }
            .pickerStyle(.segmented)
            .padding(.bottom, 4)

            if contentMode == .edit {
                NoteMarkdownToolbar(controller: markdownEditorController)
                NoteMarkdownEditor(text: $noteBody, controller: markdownEditorController)
                    .frame(minHeight: 220)
            } else {
                ScrollView {
                    NoteMarkdownRenderer(markdown: noteBody, onToggleChecklist: toggleChecklist)
                        .padding(.vertical, 8)
                }
                .frame(minHeight: 220)
            }
        }
    }

    /// Flips `[ ]`/`[x]` on the given source line — called when a checklist
    /// item is tapped in Preview mode.
    private func toggleChecklist(atLine lineIndex: Int) {
        var lines = noteBody.components(separatedBy: "\n")
        guard lines.indices.contains(lineIndex) else { return }

        if lines[lineIndex].hasPrefix("- [ ] ") {
            lines[lineIndex] = "- [x] " + lines[lineIndex].dropFirst(6)
        } else if lines[lineIndex].hasPrefix("- [x] ") || lines[lineIndex].hasPrefix("- [X] ") {
            lines[lineIndex] = "- [ ] " + lines[lineIndex].dropFirst(6)
        }

        noteBody = lines.joined(separator: "\n")
    }

    @ViewBuilder
    private var tagsSection: some View {
        Section("Tags") {
            if !tags.isEmpty {
                TagFlowLayout(spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
                        NoteTagChip(text: tag, onTap: { beginEditingTag(tag) }, onRemove: { removeTag(tag) })
                    }
                }
            }

            HStack {
                TextField("Add Tag", text: $newTagText)
                    .onSubmit(commitNewTag)
                Button(action: commitNewTag) {
                    Image(systemName: "plus.circle.fill")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.tint)
                .disabled(newTagText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    /// Trims, rejects empty input, and rejects a case-insensitive duplicate
    /// of an already-added tag before appending.
    private func commitNewTag() {
        let trimmed = newTagText.trimmingCharacters(in: .whitespacesAndNewlines)
        newTagText = ""
        guard !trimmed.isEmpty else { return }
        guard !tags.contains(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) else { return }
        tags.append(trimmed)
    }

    private func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }

    /// Tapping a chip's text (not its remove button) moves it back into the
    /// add-tag field for editing — removing it from the list and prefilling
    /// the input, so retyping and submitting replaces it.
    private func beginEditingTag(_ tag: String) {
        removeTag(tag)
        newTagText = tag
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

/// An editable tag chip — tapping the label re-opens it for editing (see
/// `NoteFormView.beginEditingTag`), tapping the "x" removes it outright.
private struct NoteTagChip: View {
    let text: String
    let onTap: () -> Void
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.subheadline)
                .onTapGesture(perform: onTap)

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .foregroundStyle(Color.accentColor)
        .background(Color.accentColor.opacity(0.15), in: Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text)
        .accessibilityAction(named: "Edit", onTap)
        .accessibilityAction(named: "Remove", onRemove)
    }
}

/// Simple wrapping row layout for tag chips — lets them flow left-to-right
/// and wrap to a new line when they run out of horizontal space, matching
/// the "[Machine Learning] [Exam Prep]" chip-cloud style rather than a
/// single scrolling row.
private struct TagFlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var rowWidth: CGFloat = 0
        var totalHeight: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth > 0, rowWidth + spacing + size.width > maxWidth {
                totalHeight += rowHeight + spacing
                rowWidth = 0
                rowHeight = 0
            }
            rowWidth += (rowWidth > 0 ? spacing : 0) + size.width
            rowHeight = max(rowHeight, size.height)
        }
        totalHeight += rowHeight
        return CGSize(width: maxWidth.isFinite ? maxWidth : rowWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > bounds.minX, x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
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
