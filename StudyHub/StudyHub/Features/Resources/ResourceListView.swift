import SwiftUI

struct ResourceListView: View {
    let bookmarkRepository: any BookmarkRepositoryProtocol
    let pdfProgressRepository: any PDFProgressRepositoryProtocol
    let pdfService: any PDFServiceProtocol

    @State private var viewModel: ResourceViewModel
    @State private var activeSheet: ResourceSheet?
    @State private var resourcePendingDelete: Resource?
    @State private var resourceForPDFViewing: Resource?
    @State private var resourceForImageViewing: Resource?
    @Environment(\.openURL) private var openURL

    init(
        course: Course,
        resourceRepository: any ResourceRepositoryProtocol,
        bookmarkRepository: any BookmarkRepositoryProtocol,
        pdfProgressRepository: any PDFProgressRepositoryProtocol,
        pdfService: any PDFServiceProtocol
    ) {
        self.bookmarkRepository = bookmarkRepository
        self.pdfProgressRepository = pdfProgressRepository
        self.pdfService = pdfService
        _viewModel = State(wrappedValue: ResourceViewModel(
            course: course,
            resourceRepository: resourceRepository
        ))
    }

    var body: some View {
        Group {
            if viewModel.resources.isEmpty {
                StudyHubEmptyState(
                    icon: "folder",
                    title: "No Resources Yet",
                    message: "Add links, files, and reference material for this course.",
                    actionTitle: "Add Resource"
                ) {
                    activeSheet = .create
                }
            } else {
                list
            }
        }
        .navigationTitle("Resources")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    activeSheet = .create
                } label: {
                    Label("Add Resource", systemImage: "plus")
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .create:
                ResourceFormView(viewModel: viewModel, resource: nil)
            case .edit(let resource):
                ResourceFormView(viewModel: viewModel, resource: resource)
            }
        }
        .alert(
            "Delete Resource?",
            isPresented: Binding(
                get: { resourcePendingDelete != nil },
                set: { isPresented in
                    if !isPresented { resourcePendingDelete = nil }
                }
            ),
            presenting: resourcePendingDelete
        ) { resource in
            Button("Delete", role: .destructive) {
                viewModel.deleteResource(resource)
            }
            Button("Cancel", role: .cancel) {}
        } message: { resource in
            Text("\"\(resource.title)\" will be permanently deleted.")
        }
        .fullScreenCover(isPresented: Binding(
            get: { resourceForPDFViewing != nil },
            set: { isPresented in
                if !isPresented { resourceForPDFViewing = nil }
            }
        )) {
            if let resourceForPDFViewing {
                let resourceNotes = resourceForPDFViewing.notes.trimmingCharacters(in: .whitespacesAndNewlines)
                NavigationStack {
                    PDFViewerView(
                        title: resourceForPDFViewing.title,
                        sourceURL: resourceForPDFViewing.url,
                        summary: resourceNotes.isEmpty ? nil : resourceNotes,
                        onSummaryEdit: { newNotes in
                            viewModel.updateResource(
                                resourceForPDFViewing,
                                title: resourceForPDFViewing.title,
                                type: resourceForPDFViewing.type,
                                url: resourceForPDFViewing.url,
                                notes: newNotes
                            )
                        },
                        initialMarkupData: resourceForPDFViewing.markupData,
                        onMarkupSave: { data in
                            viewModel.saveMarkup(data, for: resourceForPDFViewing)
                        },
                        bookmarkRepository: bookmarkRepository,
                        pdfProgressRepository: pdfProgressRepository,
                        pdfService: pdfService
                    )
                }
            }
        }
        .fullScreenCover(isPresented: Binding(
            get: { resourceForImageViewing != nil },
            set: { isPresented in
                if !isPresented { resourceForImageViewing = nil }
            }
        )) {
            if let resourceForImageViewing {
                NavigationStack {
                    ImageViewerView(resource: resourceForImageViewing)
                }
            }
        }
        .onAppear {
            viewModel.loadResources()
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

            ForEach(viewModel.resources, id: \.id) { resource in
                ResourceRowView(resource: resource)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        handleTap(on: resource)
                    }
                    .accessibilityAddTraits(.isButton)
                    .swipeActions(edge: .trailing) {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            resourcePendingDelete = resource
                        }
                        Button("Edit", systemImage: "pencil") {
                            activeSheet = .edit(resource)
                        }
                        .tint(.blue)
                    }
                    .contextMenu {
                        Button("Edit", systemImage: "pencil") {
                            activeSheet = .edit(resource)
                        }
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            resourcePendingDelete = resource
                        }
                    }
            }
        }
        .listStyle(.insetGrouped)
    }

    /// Primary row action: PDFs and Images open in their in-app viewers;
    /// Link opens via `openURL`. Resources with nothing to open (empty URL)
    /// fall back to Edit, since there's no destination to open. Editing is
    /// always still reachable via the "Edit" swipe action.
    private func handleTap(on resource: Resource) {
        guard !resource.url.isEmpty else {
            activeSheet = .edit(resource)
            return
        }

        switch resource.type {
        case .pdf:
            resourceForPDFViewing = resource
        case .image:
            resourceForImageViewing = resource
        case .link:
            if let url = URL.openable(from: resource.url) {
                openURL(url)
            } else {
                activeSheet = .edit(resource)
            }
        }
    }
}

private enum ResourceSheet: Identifiable {
    case create
    case edit(Resource)

    var id: String {
        switch self {
        case .create: return "create"
        case .edit(let resource): return resource.id.uuidString
        }
    }
}

private struct ResourceRowView: View {
    let resource: Resource

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: resource.type.icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(resource.type.color.opacity(0.85))
                .frame(width: 36, height: 36)
                .background(resource.type.color.opacity(0.14), in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(resource.title)
                    .font(.headline)

                if !resource.notes.isEmpty {
                    Text(resource.notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Text(resource.type.label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(resource.type.color)
                .padding(.horizontal, StudyHubMetrics.chipHorizontalPadding + 2)
                .padding(.vertical, StudyHubMetrics.chipVerticalPadding + 1)
                .background(resource.type.color.opacity(0.14), in: Capsule())

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(resource.title). \(resource.type.label)." +
            (resource.notes.isEmpty ? "" : " \(resource.notes).")
        )
    }
}
