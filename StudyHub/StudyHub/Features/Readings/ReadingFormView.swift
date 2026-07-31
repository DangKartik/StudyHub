import SwiftUI
import UniformTypeIdentifiers

/// Redesigned per the "final PDF/document reading integration" phase:
/// total pages, current page, and estimated minutes are no longer entered
/// here — they're derived automatically from the PDF itself (see
/// `ReadingViewModel.progress(for:)`), never from user input. The
/// attachment model is simplified from an arbitrary multi-attachment list
/// (any kind, any count) down to one primary reading source: either an
/// uploaded PDF or a plain URL, matching how a Reading is actually opened
/// elsewhere in the app (`ReadingListView.primaryAttachment(for:)`).
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
    @State private var urlText: String = ""

    @State private var existingPDFAttachment: Attachment?
    @State private var existingLinkAttachment: Attachment?
    @State private var pdfFilename: String?
    @State private var stagedTemporaryPath: String?
    @State private var isImportingPDF = false
    @State private var attachmentError: StudyHubError?
    @State private var attachmentForViewing: Attachment?
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
                }

                progressSection

                attachmentSection

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
            .navigationDestination(isPresented: Binding(
                get: { attachmentForViewing != nil },
                set: { isPresented in
                    if !isPresented { attachmentForViewing = nil }
                }
            )) {
                if let attachmentForViewing {
                    PDFViewerView(
                        attachment: attachmentForViewing,
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
            .fileImporter(isPresented: $isImportingPDF, allowedContentTypes: [.pdf]) { result in
                switch result {
                case .success(let pickedURL):
                    do {
                        let imported = try AttachmentFileImporter.importToTemporaryStorage(from: pickedURL)
                        if let stagedTemporaryPath {
                            AttachmentFileImporter.deleteTemporaryFile(at: stagedTemporaryPath)
                        }
                        stagedTemporaryPath = imported.path
                        pdfFilename = imported.filename
                    } catch let error as StudyHubError {
                        attachmentError = error
                    } catch {
                        attachmentError = AttachmentImportError.copyFailed
                    }
                case .failure:
                    attachmentError = AttachmentImportError.copyFailed
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
                    existingPDFAttachment = reading.attachments.first { AttachmentKind(rawValue: $0.type) == .pdf }
                    pdfFilename = existingPDFAttachment?.filename
                    existingLinkAttachment = reading.attachments.first { AttachmentKind(rawValue: $0.type) == .link }
                    urlText = existingLinkAttachment?.url ?? ""
                }
            }
            .onDisappear {
                if !didSaveReading, let stagedTemporaryPath {
                    AttachmentFileImporter.deleteTemporaryFile(at: stagedTemporaryPath)
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
    private var attachmentSection: some View {
        Section("Attachment") {
            Button {
                isImportingPDF = true
            } label: {
                Label(pdfFilename == nil ? "Upload PDF" : "Replace PDF", systemImage: "square.and.arrow.down")
            }

            if let pdfFilename {
                HStack {
                    Label(pdfFilename, systemImage: "doc.richtext")
                        .lineLimit(1)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if let existingPDFAttachment {
                                attachmentForViewing = existingPDFAttachment
                            }
                        }
                    Spacer()
                    Button {
                        removePDF()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }

            TextField("URL", text: $urlText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.URL)
        }
    }

    /// Removing a PDF that's only staged (not yet saved) is just local
    /// state; removing one already attached to a persisted Reading deletes
    /// it immediately, matching every other attachment-delete affordance in
    /// this app (swipe-to-delete elsewhere takes effect immediately too).
    private func removePDF() {
        if let stagedTemporaryPath {
            AttachmentFileImporter.deleteTemporaryFile(at: stagedTemporaryPath)
        }
        stagedTemporaryPath = nil
        pdfFilename = nil
        if let existingPDFAttachment {
            viewModel.deleteAttachment(existingPDFAttachment)
            self.existingPDFAttachment = nil
        }
    }

    private func saveReading() {
        let trimmedURL = urlText.trimmingCharacters(in: .whitespacesAndNewlines)

        if let reading {
            viewModel.updateReading(
                reading,
                title: title,
                author: author,
                dueDate: hasDueDate ? dueDate : nil,
                notes: notes
            )
            savePDFAttachment(to: reading)
            saveLinkAttachment(to: reading, urlText: trimmedURL)
        } else {
            didSaveReading = true
            var attachments: [Attachment] = []
            if let stagedTemporaryPath, let pdfFilename {
                attachments.append(Attachment(filename: pdfFilename, type: AttachmentKind.pdf.rawValue, url: stagedTemporaryPath))
            }
            if !trimmedURL.isEmpty {
                attachments.append(Attachment(filename: "Link", type: AttachmentKind.link.rawValue, url: trimmedURL))
            }
            viewModel.createReading(
                title: title,
                author: author,
                dueDate: hasDueDate ? dueDate : nil,
                notes: notes,
                attachments: attachments
            )
        }
        dismiss()
    }

    /// Only relevant in edit mode — create mode's PDF (if any) is handled
    /// as a staged attachment passed straight into `createReading`.
    private func savePDFAttachment(to reading: Reading) {
        guard let stagedTemporaryPath, let pdfFilename else { return }

        do {
            let finalPath = try AttachmentFileImporter.finalize(temporaryPath: stagedTemporaryPath)
            if let existingPDFAttachment {
                viewModel.deleteAttachment(existingPDFAttachment)
            }
            viewModel.addAttachment(to: reading, filename: pdfFilename, type: AttachmentKind.pdf.rawValue, url: finalPath)
        } catch let error as StudyHubError {
            attachmentError = error
        } catch {
            attachmentError = AttachmentImportError.copyFailed
        }
    }

    private func saveLinkAttachment(to reading: Reading, urlText: String) {
        let previousURL = existingLinkAttachment?.url ?? ""
        guard urlText != previousURL else { return }

        if let existingLinkAttachment {
            viewModel.deleteAttachment(existingLinkAttachment)
        }
        guard !urlText.isEmpty else { return }
        viewModel.addAttachment(to: reading, filename: "Link", type: AttachmentKind.link.rawValue, url: urlText)
    }
}
