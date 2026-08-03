import SwiftUI

struct NoteFormView: View {
    let viewModel: NotesViewModel
    let note: Note?
    let bookmarkRepository: any BookmarkRepositoryProtocol
    let pdfProgressRepository: any PDFProgressRepositoryProtocol
    let pdfService: any PDFServiceProtocol

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    @State private var title: String = ""
    @State private var noteBody: String = ""
    @State private var markdownEditorController = NoteMarkdownEditorController()
    @State private var tags: [String] = []
    @State private var newTagText: String = ""
    @State private var selectedLecture: Lecture?
    @State private var pendingAttachments: [Attachment] = []
    @State private var isAddingAttachment = false
    @State private var attachmentForViewing: Attachment?
    @State private var imageForViewing: Attachment?
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
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.vertical, 4)
                }

                contentSection

                tagsSection

                if let lectureContext = viewModel.lectureContext(for: note) {
                    Section("Attach To") {
                        Picker("Lecture", selection: $selectedLecture) {
                            Text("Course Only").tag(nil as Lecture?)
                            ForEach(lectureContext.lectures, id: \.id) { lecture in
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
                            if viewModel.lectureContext(for: note) != nil, selectedLecture?.id != note.lecture?.id {
                                viewModel.updateNoteOwnership(note, lecture: selectedLecture)
                            }
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
            .fullScreenCover(isPresented: Binding(
                get: { attachmentForViewing != nil },
                set: { isPresented in
                    if !isPresented { attachmentForViewing = nil }
                }
            )) {
                if let attachmentForViewing {
                    let noteBody = note?.body.trimmingCharacters(in: .whitespacesAndNewlines)
                    NavigationStack {
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
            }
            .fullScreenCover(isPresented: Binding(
                get: { imageForViewing != nil },
                set: { isPresented in
                    if !isPresented { imageForViewing = nil }
                }
            )) {
                if let imageForViewing {
                    NavigationStack {
                        ImageViewerView(attachment: imageForViewing)
                    }
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
                    selectedLecture = note.lecture
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
        guard AttachmentKind(rawValue: type)?.isFileBased == true else {
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
        for attachment in pendingAttachments where AttachmentKind(rawValue: attachment.type)?.isFileBased == true {
            AttachmentFileImporter.deleteTemporaryFile(at: attachment.url)
        }
    }

    /// Markdown-formatted editor (headings/bold/italic/lists/code blocks)
    /// with live inline styling — no separate Preview mode, the
    /// formatting shows directly in the same view you type in. See
    /// DECISION-033 for why formatting is stored as Markdown text in
    /// `body: String` rather than rich-text data.
    @ViewBuilder
    private var contentSection: some View {
        Section("Content") {
            NoteMarkdownToolbar(controller: markdownEditorController)
            NoteMarkdownEditor(text: $noteBody, controller: markdownEditorController)
                .frame(minHeight: 220)
        }
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
                            if AttachmentKind(rawValue: attachment.type)?.isFileBased == true {
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
                switch AttachmentKind(rawValue: attachment.type) {
                case .pdf:
                    attachmentForViewing = attachment
                case .image:
                    imageForViewing = attachment
                case .link:
                    if let url = URL.openable(from: attachment.url) {
                        openURL(url)
                    }
                case .none:
                    break
                }
            }
            .swipeActions(edge: .trailing) {
                Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
            }
    }
}

/// An editable tag chip — tapping the label re-opens it for editing (see
/// `NoteFormView.beginEditingTag`), tapping the "x" removes it outright.
/// Not `private` — also reused by `NoteDetailView`'s inline tag editor.
struct NoteTagChip: View {
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
/// single scrolling row. Not `private` — also reused by `NoteDetailView`.
struct TagFlowLayout: Layout {
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
            AttachmentIconBadge(kind: AttachmentKind(rawValue: attachment.type))
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
