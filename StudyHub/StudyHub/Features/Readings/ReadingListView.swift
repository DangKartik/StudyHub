import SwiftUI

struct ReadingListView: View {
    let bookmarkRepository: any BookmarkRepositoryProtocol
    let pdfProgressRepository: any PDFProgressRepositoryProtocol
    let pdfService: any PDFServiceProtocol

    @State private var viewModel: ReadingViewModel
    @State private var activeSheet: ReadingSheet?
    @State private var readingForPDFViewing: Reading?
    @State private var imageForViewing: Attachment?
    @Environment(\.openURL) private var openURL
    @Environment(\.colorScheme) private var colorScheme

    init(
        course: Course,
        readingRepository: any ReadingRepositoryProtocol,
        bookmarkRepository: any BookmarkRepositoryProtocol,
        pdfProgressRepository: any PDFProgressRepositoryProtocol,
        pdfService: any PDFServiceProtocol
    ) {
        self.bookmarkRepository = bookmarkRepository
        self.pdfProgressRepository = pdfProgressRepository
        self.pdfService = pdfService
        _viewModel = State(wrappedValue: ReadingViewModel(
            course: course,
            readingRepository: readingRepository,
            pdfProgressRepository: pdfProgressRepository
        ))
    }

    var body: some View {
        Group {
            if viewModel.readings.isEmpty {
                StudyHubEmptyState(
                    icon: "book",
                    title: "No Readings Yet",
                    message: "Add readings to track your course material.",
                    actionTitle: "Add Reading"
                ) {
                    activeSheet = .create
                }
            } else {
                list
            }
        }
        .navigationTitle("Readings")
        // Notes/Flashcards/Active Recall all use `.inline` (a small,
        // centered title) — Readings was the one holdout still using the
        // system's default large top-left title, which is exactly why it
        // visibly jumped in size compared to the other three tabs when
        // switching between them inside the Study Session workspace.
        .navigationBarTitleDisplayMode(.inline)
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
                ReadingFormView(viewModel: viewModel, reading: nil, bookmarkRepository: bookmarkRepository, pdfProgressRepository: pdfProgressRepository, pdfService: pdfService)
            case .edit(let reading):
                ReadingFormView(viewModel: viewModel, reading: reading, bookmarkRepository: bookmarkRepository, pdfProgressRepository: pdfProgressRepository, pdfService: pdfService)
            }
        }
        .fullScreenCover(isPresented: Binding(
            get: { readingForPDFViewing != nil },
            set: { isPresented in
                if !isPresented { readingForPDFViewing = nil }
            }
        )) {
            if let readingForPDFViewing, let attachment = primaryAttachment(for: readingForPDFViewing),
               AttachmentKind(rawValue: attachment.type) == .pdf {
                let readingNotes = readingForPDFViewing.notes.trimmingCharacters(in: .whitespacesAndNewlines)
                NavigationStack {
                    // The Reading's own title, not the attachment's raw
                    // filename — a PDF saved from Safari/Files often has an
                    // auto-generated UUID baked into its filename, which is
                    // meaningless to show as the page title.
                    PDFViewerView(
                        title: readingForPDFViewing.title,
                        sourceURL: attachment.url,
                        summary: readingNotes.isEmpty ? nil : readingNotes,
                        onSummaryEdit: { newNotes in
                            viewModel.updateReading(
                                readingForPDFViewing,
                                title: readingForPDFViewing.title,
                                author: readingForPDFViewing.author,
                                dueDate: readingForPDFViewing.dueDate,
                                notes: newNotes
                            )
                        },
                        initialMarkupData: attachment.markupData,
                        onMarkupSave: { data in
                            viewModel.saveMarkup(data, for: attachment)
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

            readingsHeroCard

            ForEach(viewModel.readings, id: \.id) { reading in
                ReadingRowView(
                    reading: reading,
                    attachment: primaryAttachment(for: reading),
                    progress: viewModel.progress(for: reading)
                )
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
                    .contextMenu {
                        Button("Edit", systemImage: "pencil") {
                            activeSheet = .edit(reading)
                        }
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            viewModel.deleteReading(reading)
                        }
                    }
            }
        }
        .listStyle(.insetGrouped)
    }

    /// Primary row action: a PDF attachment opens directly in the PDF
    /// viewer; a Link attachment opens via `openURL`; with no openable
    /// attachment, tapping opens the editor exactly as before. Editing is
    /// always still reachable via the "Edit" swipe action.
    private func handleTap(on reading: Reading) {
        guard let attachment = primaryAttachment(for: reading) else {
            activeSheet = .edit(reading)
            return
        }

        switch AttachmentKind(rawValue: attachment.type) {
        case .pdf:
            readingForPDFViewing = reading
        case .image:
            imageForViewing = attachment
        case .link:
            if let url = URL.openable(from: attachment.url) {
                openURL(url)
            } else {
                activeSheet = .edit(reading)
            }
        case .none:
            activeSheet = .edit(reading)
        }
    }

    /// Same tinted-hero composition as Home's greeting card and the Grades
    /// page's grade card — gives Readings the same "considered" top-of-page
    /// treatment instead of the list starting directly at row 1.
    private var readingsHeroCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Readings")
                .font(.system(.title2, design: .rounded).weight(.heavy))
            Text("\(viewModel.readings.count) reading\(viewModel.readings.count == 1 ? "" : "s") in this course")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: colorScheme == .dark
                    ? [Color.accentColor.opacity(0.35), Color.accentColor.opacity(0.12)]
                    : [Color.accentColor.opacity(0.16), Color.accentColor.opacity(0.03)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: StudyHubMetrics.cardCornerRadius)
        )
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }

    /// Whichever attachment was added first (PDF, Link, or Image) — not a
    /// fixed kind priority. Reading's own row/tap always reflects whatever
    /// you actually attached first, rather than a PDF you added later
    /// silently jumping ahead of an image or link you attached earlier.
    private func primaryAttachment(for reading: Reading) -> Attachment? {
        reading.attachments.min { $0.createdAt < $1.createdAt }
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
    /// Automatically derived from the PDF's own tracked position — `nil`
    /// for a non-PDF attachment or a PDF that's never been opened, both of
    /// which mean "nothing to show" (Goal 6: no progress for non-paginated
    /// content).
    let progress: (pageIndex: Int, pageCount: Int)?

    var body: some View {
        HStack(spacing: 12) {
            AttachmentIconBadge(kind: attachment.flatMap { AttachmentKind(rawValue: $0.type) })

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
                        if progressPercent != nil {
                            Text("·")
                        }
                        Text(dueDate.formatted(date: .abbreviated, time: .omitted))
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                dueStatusBadge
                if let attachment {
                    attachmentIndicator(for: attachment)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        var parts: [String] = ["\(reading.title)."]
        if !reading.author.isEmpty {
            parts.append("\(reading.author).")
        }
        if let progressPercent {
            parts.append("\(progressPercent) percent complete.")
        }
        parts.append("\(dueStatusText.label).")
        if let dueDate = reading.dueDate {
            parts.append("Due \(dueDate.formatted(date: .abbreviated, time: .omitted)).")
        }
        if let attachment {
            parts.append(attachmentLabel(for: attachment) + ".")
        }
        return parts.joined(separator: " ")
    }

    /// `pageIndex` is 0-based, so page 1 of N is `(0 + 1) / N`, not `0 / N`.
    private var progressPercent: Int? {
        guard let progress, progress.pageCount > 0 else { return nil }
        return Int((Double(progress.pageIndex + 1) / Double(progress.pageCount) * 100).rounded())
    }

    /// Label/tint for `reading.dueStatus` (shared with `ReadingViewModel`'s
    /// sort order and `HomeViewModel`'s Upcoming Readings, via
    /// `Reading.DueStatus` — never computed independently here, so the
    /// badge and the ordering can't disagree). `color` is `nil` for "Not
    /// Due" — a neutral gray badge rather than a tinted one, since there's
    /// no urgency to signal.
    private var dueStatusText: (label: String, color: Color?) {
        switch reading.dueStatus {
        case .notDue: return ("Not Due", nil)
        case .dueSoon: return ("Due Soon", .blue)
        case .dueToday: return ("Due Today", .red)
        }
    }

    private var dueStatusBadge: some View {
        let tint = dueStatusText.color
        return Text(dueStatusText.label)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(tint == nil ? Color.secondary : Color.white)
            .padding(.horizontal, StudyHubMetrics.badgeHorizontalPadding)
            .padding(.vertical, StudyHubMetrics.badgeVerticalPadding)
            .background(tint ?? Color.secondary.opacity(0.15), in: Capsule())
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
        case .image: return "View Image"
        case .none: return "View Attachment"
        }
    }
}
