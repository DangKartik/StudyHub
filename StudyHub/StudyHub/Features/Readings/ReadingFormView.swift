import SwiftUI

/// Attachments now use the same shared multi-attachment system every other
/// feature does (Notes/Lectures/Assignments/Assessments) — PDF, Link, or
/// Image, any number of them, via `AttachmentFormView`. Previously
/// Readings had its own bespoke "one primary source: PDF or URL" flow with
/// no Image support; that simplification was an intentional earlier design
/// choice, since reversed by explicit request.
struct ReadingFormView: View {
    let viewModel: ReadingViewModel
    let reading: Reading?
    let bookmarkRepository: any BookmarkRepositoryProtocol
    let pdfProgressRepository: any PDFProgressRepositoryProtocol
    let pdfService: any PDFServiceProtocol

    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var author: String = ""
    @State private var hasDueDate: Bool = false
    @State private var dueDate: Date = .now
    @State private var notes: String = ""

    @State private var pendingAttachments: [Attachment] = []
    @State private var isAddingAttachment = false
    @State private var attachmentForViewing: Attachment?
    @State private var imageForViewing: Attachment?
    @State private var attachmentError: StudyHubError?
    @State private var didSaveReading = false

    private var isEditing: Bool {
        reading != nil
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var currentAttachments: [Attachment] {
        reading?.attachments ?? pendingAttachments
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Reading") {
                    TextField("Title", text: $title)
                    TextField("Author", text: $author)
                }

                progressSection

                Section {
                    if currentAttachments.isEmpty {
                        Text("No attachments yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(currentAttachments, id: \.id) { attachment in
                            attachmentRow(attachment)
                        }
                    }

                    Button {
                        isAddingAttachment = true
                    } label: {
                        Label("Add Attachment", systemImage: "paperclip")
                    }
                } header: {
                    Label("Attachments", systemImage: "paperclip")
                }

                Section("Due Date") {
                    Toggle("Set Due Date", isOn: $hasDueDate)
                    if hasDueDate {
                        StudyHubDateField(label: "Due Date", date: $dueDate)
                    }
                }

                Section("Notes") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(isEditing ? "Edit Reading" : "New Reading")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveReading()
                    }
                    .disabled(!canSave)
                }
            }
            .sheet(isPresented: $isAddingAttachment) {
                AttachmentFormView { filename, type, tempOrURLValue in
                    if let reading {
                        commitAttachment(to: reading, filename: filename, type: type, value: tempOrURLValue)
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
                    NavigationStack {
                        PDFViewerView(
                            attachment: attachmentForViewing,
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
            .onDisappear {
                if !didSaveReading {
                    discardPendingAttachments()
                }
            }
            .onAppear {
                if let reading {
                    title = reading.title
                    author = reading.author
                    notes = reading.notes
                    if let existingDueDate = reading.dueDate {
                        hasDueDate = true
                        dueDate = existingDueDate
                    }
                }
            }
        }
    }

    /// Read-only — Goal 2's "automatically calculate" progress, shown only
    /// when there's an actual PDF with tracked progress to show. Nothing to
    /// derive progress from for a brand-new (unsaved) Reading, or one whose
    /// PDF has never been opened yet.
    @ViewBuilder
    private var progressSection: some View {
        if let reading, let progress = viewModel.progress(for: reading) {
            Section("Progress") {
                let percent = Int((Double(progress.pageIndex + 1) / Double(progress.pageCount) * 100).rounded())
                HStack {
                    Text("Page \(progress.pageIndex + 1) of \(progress.pageCount)")
                    Spacer()
                    Text("\(percent)%")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    @ViewBuilder
    private func attachmentRow(_ attachment: Attachment) -> some View {
        HStack(spacing: 8) {
            AttachmentIconBadge(kind: AttachmentKind(rawValue: attachment.type), size: 24)
            Text(attachment.filename.isEmpty ? "Attachment" : attachment.filename)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            switch AttachmentKind(rawValue: attachment.type) {
            case .pdf:
                attachmentForViewing = attachment
            case .image:
                imageForViewing = attachment
            case .link, .none:
                break
            }
        }
        .swipeActions(edge: .trailing) {
            Button("Delete", systemImage: "trash", role: .destructive) {
                removeAttachment(attachment)
            }
        }
    }

    private func commitAttachment(to reading: Reading, filename: String, type: String, value: String) {
        guard AttachmentKind(rawValue: type)?.isFileBased == true else {
            viewModel.addAttachment(to: reading, filename: filename, type: type, url: value)
            return
        }

        do {
            let finalPath = try AttachmentFileImporter.finalize(temporaryPath: value)
            viewModel.addAttachment(to: reading, filename: filename, type: type, url: finalPath)
        } catch let error as StudyHubError {
            attachmentError = error
        } catch {
            attachmentError = AttachmentImportError.copyFailed
        }
    }

    private func removeAttachment(_ attachment: Attachment) {
        if reading != nil {
            viewModel.deleteAttachment(attachment)
        } else {
            pendingAttachments.removeAll { $0.id == attachment.id }
            if AttachmentKind(rawValue: attachment.type)?.isFileBased == true {
                AttachmentFileImporter.deleteTemporaryFile(at: attachment.url)
            }
        }
    }

    private func discardPendingAttachments() {
        for attachment in pendingAttachments where AttachmentKind(rawValue: attachment.type)?.isFileBased == true {
            AttachmentFileImporter.deleteTemporaryFile(at: attachment.url)
        }
    }

    private func saveReading() {
        if let reading {
            viewModel.updateReading(
                reading,
                title: title,
                author: author,
                dueDate: hasDueDate ? dueDate : nil,
                notes: notes
            )
        } else {
            didSaveReading = true
            viewModel.createReading(
                title: title,
                author: author,
                dueDate: hasDueDate ? dueDate : nil,
                notes: notes,
                attachments: pendingAttachments
            )
        }
        dismiss()
    }
}
