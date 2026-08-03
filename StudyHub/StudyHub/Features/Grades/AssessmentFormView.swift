import SwiftUI

/// Replaces the former separate `QuizFormView`/`ExamFormView` — both models
/// merged into one `Assessment` with a Kind picker, so one form handles
/// both now.
struct AssessmentFormView: View {
    let viewModel: GradesViewModel
    let assessment: Assessment?
    var initialKind: AssessmentKind = .quiz
    let bookmarkRepository: any BookmarkRepositoryProtocol
    let pdfProgressRepository: any PDFProgressRepositoryProtocol
    let pdfService: any PDFServiceProtocol

    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var kind: AssessmentKind = .quiz
    @State private var date: Date = .now
    @State private var time: Date = .now
    @State private var endTime: Date = .now
    @State private var location: String = ""
    @State private var weight: Double = 0
    @State private var isGraded: Bool = false
    @State private var score: Double = 0
    @State private var maximumScore: Double = 100
    @State private var notes: String = ""
    @State private var pendingAttachments: [Attachment] = []
    @State private var isAddingAttachment = false
    @State private var attachmentForViewing: Attachment?
    @State private var imageForViewing: Attachment?
    @State private var attachmentError: StudyHubError?
    @State private var didSaveAssessment = false
    @State private var isEditingReflection = false

    private var isEditing: Bool {
        assessment != nil
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && weight <= remainingWeight
    }

    private var remainingWeight: Double {
        viewModel.remainingWeight(excludingID: assessment?.id)
    }

    private var currentAttachments: [Attachment] {
        assessment?.attachments ?? pendingAttachments
    }

    /// Combines the separately-edited date and time pickers into one
    /// `Date` — mirrors `AssignmentFormView.resolvedDueDate`.
    private var resolvedDate: Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        components.second = timeComponents.second
        return calendar.date(from: components) ?? date
    }

    /// `duration` is stored as a plain `TimeInterval` on `Assessment`, but
    /// editing it as an End Time (like Lecture's Start/End) reads far more
    /// naturally than typing minutes — only the hour/minute of each picker
    /// matters, so this compares time-of-day rather than full dates. An end
    /// time picked "before" the start time clamps to zero rather than
    /// wrapping past midnight.
    private var resolvedDuration: TimeInterval {
        let calendar = Calendar.current
        let startMinutes = calendar.component(.hour, from: time) * 60 + calendar.component(.minute, from: time)
        let endMinutes = calendar.component(.hour, from: endTime) * 60 + calendar.component(.minute, from: endTime)
        return TimeInterval(max(0, endMinutes - startMinutes) * 60)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker(selection: $kind) {
                        ForEach(AssessmentKind.allCases, id: \.self) { kind in
                            Text(kind.label).tag(kind)
                        }
                    } label: {
                        Text("Kind")
                    }
                    .pickerStyle(.menu)

                    TextField("Title", text: $title)
                    StudyHubDateField(label: "Date", date: $date)
                    StudyHubTimeField(label: "Start Time", time: $time)
                    StudyHubTimeField(label: "End Time", time: $endTime)
                    TextField("Location", text: $location)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Weight (%)")
                            Spacer()
                            SelectAllNumberField(value: $weight, keyboardType: .decimalPad)
                        }
                        if weight > remainingWeight {
                            Text("Only \(remainingWeight, specifier: "%.0f")% left to assign for this course.")
                                .font(.caption)
                                .foregroundStyle(.red)
                        } else {
                            Text("\(remainingWeight, specifier: "%.0f")% unassigned across this course's quizzes and exams.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Label(kind.label, systemImage: kind.icon)
                }

                Section("Score") {
                    Toggle("Graded", isOn: $isGraded)

                    if isGraded {
                        HStack {
                            Text("Score")
                            Spacer()
                            SelectAllNumberField(value: $score, keyboardType: .decimalPad)
                        }
                    }

                    HStack {
                        Text("Maximum Score")
                        Spacer()
                        SelectAllNumberField(value: $maximumScore, keyboardType: .decimalPad)
                    }
                }

                Section("Notes") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                if let assessment, assessment.isPast {
                    reflectionSection(for: assessment)
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
            .navigationTitle(isEditing ? "Edit \(kind.label)" : "New \(kind.label)")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        didSaveAssessment = true
                        if let assessment {
                            viewModel.updateAssessment(
                                assessment,
                                title: title,
                                kind: kind,
                                date: resolvedDate,
                                location: location,
                                duration: resolvedDuration,
                                weight: weight,
                                score: isGraded ? score : nil,
                                maximumScore: maximumScore,
                                notes: notes
                            )
                        } else {
                            viewModel.createAssessment(
                                title: title,
                                kind: kind,
                                date: resolvedDate,
                                location: location,
                                duration: resolvedDuration,
                                weight: weight,
                                score: isGraded ? score : nil,
                                maximumScore: maximumScore,
                                notes: notes,
                                attachments: pendingAttachments
                            )
                        }
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
            .sheet(isPresented: $isEditingReflection) {
                if let assessment {
                    AssessmentReflectionView(
                        assessment: assessment,
                        onSubmit: { rating, note in
                            viewModel.saveReflection(for: assessment, rating: rating, note: note)
                        },
                        onSkip: {}
                    )
                }
            }
            .sheet(isPresented: $isAddingAttachment) {
                AttachmentFormView { filename, type, tempOrURLValue in
                    if let assessment {
                        commitAttachment(to: assessment, filename: filename, type: type, value: tempOrURLValue)
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
                if !didSaveAssessment {
                    discardPendingAttachments()
                }
            }
            .onAppear {
                if let assessment {
                    title = assessment.title
                    kind = assessment.kind
                    date = assessment.date
                    time = assessment.date
                    endTime = assessment.date.addingTimeInterval(assessment.duration)
                    location = assessment.location
                    weight = assessment.weight
                    maximumScore = assessment.maximumScore
                    notes = assessment.notes
                    if let existingScore = assessment.score {
                        isGraded = true
                        score = existingScore
                    }
                } else {
                    kind = initialKind
                    let start = Date.nextFullHour(from: .now)
                    time = start
                    endTime = Calendar.current.date(byAdding: .minute, value: 60, to: start) ?? start
                }
            }
        }
    }

    /// Read-only display of the personal "how did it go" reflection
    /// captured via the post-assessment popup (`AssessmentReflectionView`,
    /// triggered from `RootView`) — that flow only shows once per
    /// assessment, so this is the only other place to see or change what
    /// was answered.
    @ViewBuilder
    private func reflectionSection(for assessment: Assessment) -> some View {
        Section {
            if assessment.hasReflected {
                if let rating = assessment.reflectionRating {
                    HStack(spacing: 4) {
                        ForEach(1...5, id: \.self) { value in
                            Image(systemName: rating >= value ? "star.fill" : "star")
                                .foregroundStyle(rating >= value ? .yellow : .secondary)
                        }
                    }
                }
                let trimmedNote = assessment.reflectionNote.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmedNote.isEmpty {
                    Text(assessment.reflectionNote)
                        .foregroundStyle(.secondary)
                }
                Button("Edit Reflection") {
                    isEditingReflection = true
                }
            } else {
                Text("Not answered yet.")
                    .foregroundStyle(.secondary)
                Button("Rate How It Went") {
                    isEditingReflection = true
                }
            }
        } header: {
            Label("Your Reflection", systemImage: "star.fill")
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

    private func commitAttachment(to assessment: Assessment, filename: String, type: String, value: String) {
        guard AttachmentKind(rawValue: type)?.isFileBased == true else {
            viewModel.addAttachment(to: assessment, filename: filename, type: type, url: value)
            return
        }

        do {
            let finalPath = try AttachmentFileImporter.finalize(temporaryPath: value)
            viewModel.addAttachment(to: assessment, filename: filename, type: type, url: finalPath)
        } catch let error as StudyHubError {
            attachmentError = error
        } catch {
            attachmentError = AttachmentImportError.copyFailed
        }
    }

    private func removeAttachment(_ attachment: Attachment) {
        if assessment != nil {
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
