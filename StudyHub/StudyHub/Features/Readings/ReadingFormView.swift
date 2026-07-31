import SwiftUI
import UniformTypeIdentifiers

struct ReadingFormView: View {
    let viewModel: ReadingViewModel
    let reading: Reading?
    let bookmarkRepository: any BookmarkRepositoryProtocol
    let pdfService: any PDFServiceProtocol

    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var author: String = ""
    @State private var pageCount: Int = 0
    @State private var currentPage: Int = 0
    @State private var estimatedMinutes: Int = 0
    @State private var hasDueDate: Bool = false
    @State private var dueDate: Date = .now
    @State private var notes: String = ""

    @State private var pendingAttachments: [Attachment] = []
    @State private var isAddingAttachment = false
    @State private var attachmentForViewing: Attachment?
    @State private var attachmentError: StudyHubError?
    @State private var didSaveReading = false

    private var isEditing: Bool {
        reading != nil
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Reading") {
                    TextField("Title", text: $title)
                    TextField("Author", text: $author)

                    HStack {
                        Text("Total Pages")
                        Spacer()
                        SelectAllNumberField(value: $pageCount)
                            .onChange(of: pageCount) { _, newValue in
                                if newValue < 0 { pageCount = 0 }
                                if currentPage > pageCount { currentPage = pageCount }
                            }
                    }

                    HStack {
                        Text("Current Page")
                        Spacer()
                        SelectAllNumberField(value: $currentPage)
                            .onChange(of: currentPage) { _, newValue in
                                if newValue < 0 {
                                    currentPage = 0
                                } else if newValue > pageCount {
                                    currentPage = pageCount
                                }
                            }
                    }

                    HStack {
                        Text("Estimated Minutes")
                        Spacer()
                        SelectAllNumberField(value: $estimatedMinutes)
                            .onChange(of: estimatedMinutes) { _, newValue in
                                if newValue < 0 { estimatedMinutes = 0 }
                            }
                    }
                }

                Section("Due Date") {
                    Toggle("Set Due Date", isOn: $hasDueDate)
                    if hasDueDate {
                        StudyHubDateField(label: "Due Date", date: $dueDate)
                    }
                }

                attachmentsSection

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
                // Always stages to temporary storage and never finalizes
                // itself — the caller decides when a file becomes permanent,
                // mirroring NoteFormView's AttachmentFormView pattern.
                ReadingAttachmentFormView { filename, type, tempOrURLValue in
                    if let reading {
                        commitAttachment(to: reading, filename: filename, type: type, value: tempOrURLValue)
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
                    PDFViewerView(attachment: attachmentForViewing, bookmarkRepository: bookmarkRepository, pdfService: pdfService)
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
                if let reading {
                    title = reading.title
                    author = reading.author
                    pageCount = reading.pageCount
                    currentPage = reading.currentPage
                    estimatedMinutes = reading.estimatedMinutes
                    notes = reading.notes
                    if let existingDueDate = reading.dueDate {
                        hasDueDate = true
                        dueDate = existingDueDate
                    }
                }
            }
            .onDisappear {
                if !didSaveReading {
                    discardPendingAttachments()
                }
            }
        }
    }

    private func saveReading() {
        if let reading {
            viewModel.updateReading(
                reading,
                title: title,
                author: author,
                pageCount: pageCount,
                currentPage: currentPage,
                estimatedMinutes: estimatedMinutes,
                dueDate: hasDueDate ? dueDate : nil,
                notes: notes
            )
        } else {
            didSaveReading = true
            viewModel.createReading(
                title: title,
                author: author,
                pageCount: pageCount,
                currentPage: currentPage,
                estimatedMinutes: estimatedMinutes,
                dueDate: hasDueDate ? dueDate : nil,
                notes: notes,
                attachments: pendingAttachments
            )
        }
        dismiss()
    }

    /// Editing an existing, already-persisted Reading: the attachment is
    /// being committed right now, not staged for a later Save.
    private func commitAttachment(to reading: Reading, filename: String, type: String, value: String) {
        guard type == AttachmentKind.pdf.rawValue else {
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

    private func discardPendingAttachments() {
        for attachment in pendingAttachments where attachment.type == AttachmentKind.pdf.rawValue {
            AttachmentFileImporter.deleteTemporaryFile(at: attachment.url)
        }
    }

    @ViewBuilder
    private var attachmentsSection: some View {
        Section("Attachments") {
            if let reading {
                if reading.attachments.isEmpty {
                    Text("No attachments yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(reading.attachments.sorted { $0.createdAt < $1.createdAt }, id: \.id) { attachment in
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
        ReadingAttachmentRowView(attachment: attachment)
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

private struct ReadingAttachmentRowView: View {
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

private struct ReadingAttachmentFormView: View {
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
