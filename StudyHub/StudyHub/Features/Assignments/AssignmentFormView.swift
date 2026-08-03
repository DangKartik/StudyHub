import SwiftUI

struct AssignmentFormView: View {
    let viewModel: AssignmentsViewModel
    let assignment: Assignment?
    let bookmarkRepository: any BookmarkRepositoryProtocol
    let pdfProgressRepository: any PDFProgressRepositoryProtocol
    let pdfService: any PDFServiceProtocol

    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var dueDate: Date = .now
    @State private var dueTime: Date = AssignmentFormView.defaultDueTime
    @State private var priority: Priority = .medium
    @State private var status: AssignmentStatus = .notStarted
    @State private var assignmentDescription: String = ""
    @State private var estimatedHours: Double = 0
    @State private var pendingAttachments: [Attachment] = []
    @State private var isAddingAttachment = false
    @State private var attachmentForViewing: Attachment?
    @State private var imageForViewing: Attachment?
    @State private var attachmentError: StudyHubError?
    @State private var didSaveAssignment = false

    private static let selectableStatuses: [AssignmentStatus] = [.notStarted, .inProgress, .completed]

    private static var defaultDueTime: Date {
        Calendar.current.date(bySettingHour: 23, minute: 59, second: 0, of: .now) ?? .now
    }

    private var isEditing: Bool {
        assignment != nil
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var resolvedDueDate: Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: dueDate)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: dueTime)
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        components.second = timeComponents.second
        return calendar.date(from: components) ?? dueDate
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                    StudyHubDateField(label: "Due Date", date: $dueDate)
                    StudyHubTimeField(label: "Due Time", time: $dueTime)
                    Picker("Priority", selection: $priority) {
                        ForEach(Priority.allCases, id: \.self) { priority in
                            Text(priority.label).tag(priority)
                        }
                    }
                    Stepper(
                        "Estimated Hours: \(estimatedHours, specifier: "%.1f")",
                        value: $estimatedHours,
                        in: 0...100,
                        step: 0.5
                    )
                } header: {
                    Label("Assignment", systemImage: "checklist")
                }

                Section {
                    Picker("Status", selection: $status) {
                        ForEach(Self.selectableStatuses, id: \.self) { status in
                            Text(status.label).tag(status)
                        }
                    }
                } header: {
                    Label("Status", systemImage: "flag.fill")
                }

                Section {
                    TextField("Description", text: $assignmentDescription, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Label("Description", systemImage: "text.alignleft")
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
            .navigationTitle(isEditing ? "Edit Assignment" : "New Assignment")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        didSaveAssignment = true
                        if let assignment {
                            viewModel.updateAssignment(
                                assignment,
                                title: title,
                                dueDate: resolvedDueDate,
                                priority: priority,
                                status: status,
                                description: assignmentDescription,
                                estimatedHours: estimatedHours
                            )
                        } else {
                            viewModel.createAssignment(
                                title: title,
                                dueDate: resolvedDueDate,
                                priority: priority,
                                status: status,
                                description: assignmentDescription,
                                estimatedHours: estimatedHours,
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
                    if let assignment {
                        commitAttachment(to: assignment, filename: filename, type: type, value: tempOrURLValue)
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
                if !didSaveAssignment {
                    discardPendingAttachments()
                }
            }
            .onAppear {
                if let assignment {
                    title = assignment.title
                    dueDate = assignment.dueDate
                    dueTime = assignment.dueDate
                    priority = assignment.priority
                    status = assignment.status
                    assignmentDescription = assignment.assignmentDescription
                    estimatedHours = assignment.estimatedHours
                }
            }
        }
    }

    private var currentAttachments: [Attachment] {
        assignment?.attachments ?? pendingAttachments
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

    /// Editing an existing, already-persisted Assignment: the attachment is
    /// being committed right now, not staged for a later Save — mirrors
    /// `NoteFormView.commitAttachment`/`LectureFormView.commitAttachment`.
    private func commitAttachment(to assignment: Assignment, filename: String, type: String, value: String) {
        guard AttachmentKind(rawValue: type)?.isFileBased == true else {
            viewModel.addAttachment(to: assignment, filename: filename, type: type, url: value)
            return
        }

        do {
            let finalPath = try AttachmentFileImporter.finalize(temporaryPath: value)
            viewModel.addAttachment(to: assignment, filename: filename, type: type, url: finalPath)
        } catch let error as StudyHubError {
            attachmentError = error
        } catch {
            attachmentError = AttachmentImportError.copyFailed
        }
    }

    private func removeAttachment(_ attachment: Attachment) {
        if assignment != nil {
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
}
