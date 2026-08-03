import SwiftUI

struct LectureFormView: View {
    let viewModel: LectureViewModel
    let lecture: Lecture?
    let bookmarkRepository: any BookmarkRepositoryProtocol
    let pdfProgressRepository: any PDFProgressRepositoryProtocol
    let pdfService: any PDFServiceProtocol
    /// `nil` for the one call site that only ever edits an existing lecture
    /// (Flashcards' "view linked lecture" sheet) — the smart defaults below
    /// only apply when creating, so that site never needs this anyway. The
    /// default here (rather than a required param) is what lets that call
    /// site keep compiling unchanged.
    var userPreferences: UserPreferences? = nil

    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var topic: String = ""
    @State private var date: Date = .now
    @State private var startTime: Date = .now
    @State private var endTime: Date = .now
    @State private var location: String = ""
    @State private var summary: String = ""
    @State private var pendingAttachments: [Attachment] = []
    @State private var isAddingAttachment = false
    @State private var attachmentForViewing: Attachment?
    @State private var imageForViewing: Attachment?
    @State private var attachmentError: StudyHubError?
    @State private var didSaveLecture = false

    private var isEditing: Bool {
        lecture != nil
    }

    private var canSave: Bool {
        !topic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                    TextField("Topic", text: $topic)
                    StudyHubDateField(label: "Date", date: $date)
                    StudyHubTimeField(label: "Start Time", time: $startTime)
                    StudyHubTimeField(label: "End Time", time: $endTime)
                    TextField("Location", text: $location)
                } header: {
                    Label("Lecture", systemImage: "list.bullet")
                }

                Section {
                    TextField("Summary", text: $summary, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Label("Summary", systemImage: "text.alignleft")
                }

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
            }
            .navigationTitle(isEditing ? "Edit Lecture" : "New Lecture")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        didSaveLecture = true
                        if let lecture {
                            viewModel.updateLecture(
                                lecture,
                                title: title,
                                topic: topic,
                                date: date,
                                startTime: startTime,
                                endTime: endTime,
                                location: location,
                                summary: summary
                            )
                        } else {
                            viewModel.createLecture(
                                title: title,
                                topic: topic,
                                date: date,
                                startTime: startTime,
                                endTime: endTime,
                                location: location,
                                summary: summary,
                                attachments: pendingAttachments
                            )
                        }
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
            .sheet(isPresented: $isAddingAttachment) {
                AttachmentFormView { filename, type, tempOrURLValue in
                    if let lecture {
                        commitAttachment(to: lecture, filename: filename, type: type, value: tempOrURLValue)
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
                if !didSaveLecture {
                    discardPendingAttachments()
                }
            }
            .onAppear {
                if let lecture {
                    title = lecture.title
                    topic = lecture.topic
                    date = lecture.date
                    startTime = lecture.startTime
                    endTime = lecture.endTime
                    location = lecture.location
                    summary = lecture.summary
                } else {
                    let start = Date.nextFullHour(from: .now)
                    let durationMinutes = userPreferences?.defaultLectureDurationMinutes ?? 60
                    startTime = start
                    endTime = Calendar.current.date(byAdding: .minute, value: durationMinutes, to: start) ?? start
                }
            }
        }
    }

    private var currentAttachments: [Attachment] {
        lecture?.attachments ?? pendingAttachments
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

    /// Editing an existing, already-persisted Lecture: the attachment is
    /// being committed right now, not staged for a later Save — mirrors
    /// `NoteFormView.commitAttachment`.
    private func commitAttachment(to lecture: Lecture, filename: String, type: String, value: String) {
        guard AttachmentKind(rawValue: type)?.isFileBased == true else {
            viewModel.addAttachment(to: lecture, filename: filename, type: type, url: value)
            return
        }

        do {
            let finalPath = try AttachmentFileImporter.finalize(temporaryPath: value)
            viewModel.addAttachment(to: lecture, filename: filename, type: type, url: finalPath)
        } catch let error as StudyHubError {
            attachmentError = error
        } catch {
            attachmentError = AttachmentImportError.copyFailed
        }
    }

    /// An existing lecture's attachment is already persisted, so removing it
    /// deletes it immediately; a brand-new lecture's attachment is only
    /// staged locally, so removing it just drops it from
    /// `pendingAttachments` (cleaning up its temp file if file-based).
    private func removeAttachment(_ attachment: Attachment) {
        if lecture != nil {
            viewModel.deleteAttachment(attachment)
        } else {
            pendingAttachments.removeAll { $0.id == attachment.id }
            if AttachmentKind(rawValue: attachment.type)?.isFileBased == true {
                AttachmentFileImporter.deleteTemporaryFile(at: attachment.url)
            }
        }
    }

    /// Deletes the temporary files backing any staged-but-never-saved
    /// file-based attachments — called when this form disappears without
    /// having been saved.
    private func discardPendingAttachments() {
        for attachment in pendingAttachments where AttachmentKind(rawValue: attachment.type)?.isFileBased == true {
            AttachmentFileImporter.deleteTemporaryFile(at: attachment.url)
        }
    }
}
