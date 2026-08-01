import SwiftUI

/// Full-screen editor for a Note — the single place title, tags, body, and
/// attachments all get edited, for both creating a new note (`note == nil`,
/// reached from the "Add Note" toolbar button) and editing an existing one
/// (reached from `NoteDetailView`'s "Edit" button, which itself stays purely
/// read-only).
struct NoteBodyEditorView: View {
    let note: Note?
    let viewModel: NotesViewModel

    @State private var title: String
    @State private var tags: [String]
    @State private var newTagText: String = ""
    @State private var bodyText: String
    @State private var selectedLecture: Lecture?
    @State private var pendingAttachments: [Attachment] = []
    @State private var markdownEditorController = NoteMarkdownEditorController()
    @State private var isAddingAttachment = false
    @State private var attachmentError: StudyHubError?
    @State private var didSaveNote = false
    @Environment(\.dismiss) private var dismiss

    private var isEditing: Bool {
        note != nil
    }

    init(note: Note?, viewModel: NotesViewModel) {
        self.note = note
        self.viewModel = viewModel
        _title = State(initialValue: note?.title ?? "")
        _tags = State(initialValue: note?.tags ?? [])
        _bodyText = State(initialValue: note?.body ?? "")
        _selectedLecture = State(initialValue: note?.lecture)
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                titleAndTags

                if viewModel.isCourseScope {
                    lecturePicker
                }

                Divider()
                    .padding(.top, 12)
                NoteMarkdownToolbar(controller: markdownEditorController)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                Divider()
                NoteMarkdownEditor(text: $bodyText, controller: markdownEditorController)
            }
            .navigationTitle(isEditing ? "Edit Note" : "New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isAddingAttachment = true
                    } label: {
                        Label("Add Attachment", systemImage: "paperclip")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        save()
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
            .sheet(isPresented: $isAddingAttachment) {
                AttachmentFormView { filename, type, tempOrURLValue in
                    if let note {
                        commitAttachment(to: note, filename: filename, type: type, value: tempOrURLValue)
                    } else {
                        pendingAttachments.append(Attachment(filename: filename, type: type, url: tempOrURLValue))
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
            .onDisappear {
                if !didSaveNote {
                    discardPendingAttachments()
                }
            }
        }
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if let note {
            viewModel.updateNote(note, title: trimmedTitle, body: bodyText, tags: tags)
            if viewModel.isCourseScope, selectedLecture?.id != note.lecture?.id {
                viewModel.updateNoteOwnership(note, lecture: selectedLecture)
            }
        } else {
            didSaveNote = true
            viewModel.createNote(
                title: trimmedTitle,
                body: bodyText,
                lecture: selectedLecture,
                tags: tags,
                attachments: pendingAttachments
            )
        }
    }

    private var titleAndTags: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Title", text: $title)
                .font(.title3)
                .fontWeight(.semibold)

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
        .padding(.horizontal)
        .padding(.top, 8)
    }

    /// Shown from Course scope (DECISION-030) — lets a note optionally
    /// target one of the course's Lectures instead of attaching directly to
    /// the Course. Shown for both creation and editing: a note reached from
    /// Course scope is always Course- or Lecture-owned (never
    /// Reading-owned, see `NoteRepository.fetch(forCourseIncludingLectures:)`),
    /// so re-linking it here is always well-defined.
    /// Outside a `Form`/`List`, `Picker`'s own title never renders — only
    /// the selected value shows, as a bare menu button with no context for
    /// what it's choosing. An explicit leading label fixes that.
    private var lecturePicker: some View {
        HStack(spacing: 8) {
            Text("Lecture")
            Picker("Lecture", selection: $selectedLecture) {
                Text("Course Only").tag(nil as Lecture?)
                ForEach(viewModel.availableLectures, id: \.id) { lecture in
                    Text(lecture.topic).tag(Optional(lecture))
                }
            }
            .labelsHidden()

            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 4)
    }

    /// Trims, rejects empty input, and rejects a case-insensitive duplicate
    /// of an already-added tag before appending — same rule as
    /// `NoteFormView.commitNewTag`, but this list only actually saves on
    /// "Done", along with the title and body.
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

    /// Mirrors `NoteFormView.commitAttachment` for the already-persisted-note
    /// case: a staged PDF's value is a temporary path that needs finalizing
    /// into permanent storage first; every other kind is already a plain
    /// reference string with nothing to move. Attachments to an existing
    /// note save immediately (unlike title/tags/body); a brand-new note has
    /// nothing to attach to yet, so its attachments stay staged in
    /// `pendingAttachments` until "Done" actually creates the note.
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
    /// attachments — called when this editor disappears without a new note
    /// having been saved (Cancel, swipe-to-dismiss, or any other dismissal).
    private func discardPendingAttachments() {
        for attachment in pendingAttachments where attachment.type == AttachmentKind.pdf.rawValue {
            AttachmentFileImporter.deleteTemporaryFile(at: attachment.url)
        }
    }
}
