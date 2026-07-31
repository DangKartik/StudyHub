import SwiftUI

struct ReadingListView: View {
    let pdfService: any PDFServiceProtocol

    @State private var viewModel: ReadingViewModel
    @State private var activeSheet: ReadingSheet?
    @State private var readingForPDFViewing: Reading?
    @Environment(\.openURL) private var openURL

    init(course: Course, readingRepository: any ReadingRepositoryProtocol, pdfService: any PDFServiceProtocol) {
        self.pdfService = pdfService
        _viewModel = State(wrappedValue: ReadingViewModel(
            course: course,
            readingRepository: readingRepository
        ))
    }

    var body: some View {
        Group {
            if viewModel.readings.isEmpty {
                StudyHubEmptyState(
                    icon: "book",
                    title: "No Readings Yet",
                    message: "Add readings to track your course material."
                )
            } else {
                list
            }
        }
        .navigationTitle("Readings")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    activeSheet = .create
                } label: {
                    Label("Add Reading", systemImage: "plus")
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .create:
                ReadingFormView(viewModel: viewModel, reading: nil, pdfService: pdfService)
            case .edit(let reading):
                ReadingFormView(viewModel: viewModel, reading: reading, pdfService: pdfService)
            }
        }
        .navigationDestination(isPresented: Binding(
            get: { readingForPDFViewing != nil },
            set: { isPresented in
                if !isPresented { readingForPDFViewing = nil }
            }
        )) {
            if let readingForPDFViewing, let attachment = primaryAttachment(for: readingForPDFViewing),
               AttachmentKind(rawValue: attachment.type) == .pdf {
                let readingNotes = readingForPDFViewing.notes.trimmingCharacters(in: .whitespacesAndNewlines)
                PDFViewerView(
                    attachment: attachment,
                    summary: readingNotes.isEmpty ? nil : readingNotes,
                    onSummaryEdit: { newNotes in
                        viewModel.updateReading(
                            readingForPDFViewing,
                            title: readingForPDFViewing.title,
                            author: readingForPDFViewing.author,
                            pageCount: readingForPDFViewing.pageCount,
                            currentPage: readingForPDFViewing.currentPage,
                            estimatedMinutes: readingForPDFViewing.estimatedMinutes,
                            dueDate: readingForPDFViewing.dueDate,
                            notes: newNotes
                        )
                    },
                    onMarkupSave: { data in
                        viewModel.saveMarkup(data, for: attachment)
                    },
                    pdfService: pdfService
                )
            }
        }
        .onAppear {
            viewModel.loadReadings()
        }
    }

    private var list: some View {
        List {
            if let error = viewModel.loadError {
                Section {
                    Text(error.message)
                        .foregroundStyle(.red)
                }
            }

            ForEach(viewModel.readings, id: \.id) { reading in
                ReadingRowView(reading: reading, attachment: primaryAttachment(for: reading))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        handleTap(on: reading)
                    }
                    .accessibilityAddTraits(.isButton)
                    .swipeActions(edge: .trailing) {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            viewModel.deleteReading(reading)
                        }
                        Button("Edit", systemImage: "pencil") {
                            activeSheet = .edit(reading)
                        }
                        .tint(.blue)
                    }
            }
        }
        .listStyle(.insetGrouped)
    }

    /// Primary row action: a PDF attachment opens directly in the PDF
    /// viewer; a Link/GoodNotes attachment opens via `openURL`; with no
    /// openable attachment, tapping opens the editor exactly as before.
    /// Editing is always still reachable via the "Edit" swipe action.
    private func handleTap(on reading: Reading) {
        guard let attachment = primaryAttachment(for: reading) else {
            activeSheet = .edit(reading)
            return
        }

        switch AttachmentKind(rawValue: attachment.type) {
        case .pdf:
            readingForPDFViewing = reading
        case .link, .goodnotes:
            if let url = URL(string: attachment.url) {
                openURL(url)
            } else {
                activeSheet = .edit(reading)
            }
        default:
            // Image/Document/Other have no in-app viewer anywhere in this
            // app yet (Notes has the same gap) — fall back to Edit.
            activeSheet = .edit(reading)
        }
    }

    /// PDF takes priority (matching every other opening-behavior entry
    /// point in the app); otherwise the first attachment of any kind, so
    /// the row's indicator and tap behavior always reflect *something*
    /// openable rather than silently hiding it.
    private func primaryAttachment(for reading: Reading) -> Attachment? {
        if let pdf = reading.attachments.first(where: { AttachmentKind(rawValue: $0.type) == .pdf }) {
            return pdf
        }
        return reading.attachments.first
    }
}

private enum ReadingSheet: Identifiable {
    case create
    case edit(Reading)

    var id: String {
        switch self {
        case .create: return "create"
        case .edit(let reading): return reading.id.uuidString
        }
    }
}

private struct ReadingRowView: View {
    let reading: Reading
    let attachment: Attachment?

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(reading.title)
                    .font(.headline)

                if !reading.author.isEmpty {
                    Text(reading.author)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 6) {
                    if let progressPercent {
                        Text("\(progressPercent)% Complete")
                    }
                    if let dueDate = reading.dueDate {
                        Text("· Due \(dueDate.formatted(date: .abbreviated, time: .omitted))")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            if let attachment {
                attachmentIndicator(for: attachment)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(reading.title)." +
            (reading.author.isEmpty ? "" : " \(reading.author).") +
            (progressPercent.map { " \($0) percent complete." } ?? "") +
            (reading.dueDate.map { " Due \($0.formatted(date: .abbreviated, time: .omitted))." } ?? "") +
            (attachment.map { " \(attachmentLabel(for: $0))." } ?? "")
        )
    }

    private var progressPercent: Int? {
        guard reading.pageCount > 0 else { return nil }
        return Int((Double(reading.currentPage) / Double(reading.pageCount) * 100).rounded())
    }

    /// The row never hides an attachment behind a tap-and-see interaction —
    /// its kind and the resulting action (View PDF / Open URL / View <kind>)
    /// are always visible on the row's trailing edge.
    @ViewBuilder
    private func attachmentIndicator(for attachment: Attachment) -> some View {
        let kind = AttachmentKind(rawValue: attachment.type)
        Label(attachmentLabel(for: attachment), systemImage: kind?.icon ?? "paperclip")
            .font(.caption)
            .foregroundStyle(.secondary)
            .labelStyle(.titleAndIcon)
    }

    private func attachmentLabel(for attachment: Attachment) -> String {
        switch AttachmentKind(rawValue: attachment.type) {
        case .pdf: return "View PDF"
        case .link: return "Open URL"
        case .goodnotes: return "Open GoodNotes"
        case .image: return "View Image"
        case .document: return "View Document"
        case .other, .none: return "View Attachment"
        }
    }
}
