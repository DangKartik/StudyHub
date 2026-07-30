import SwiftUI

struct ResourceListView: View {
    let pdfService: any PDFServiceProtocol

    @State private var viewModel: ResourceViewModel
    @State private var activeSheet: ResourceSheet?
    @State private var resourcePendingDelete: Resource?
    @State private var resourceForPDFViewing: Resource?
    @Environment(\.openURL) private var openURL

    init(course: Course, resourceRepository: any ResourceRepositoryProtocol, pdfService: any PDFServiceProtocol) {
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
                    message: "Add links, files, and reference material for this course."
                )
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
        .navigationDestination(isPresented: Binding(
            get: { resourceForPDFViewing != nil },
            set: { isPresented in
                if !isPresented { resourceForPDFViewing = nil }
            }
        )) {
            if let resourceForPDFViewing {
                let resourceNotes = resourceForPDFViewing.notes.trimmingCharacters(in: .whitespacesAndNewlines)
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
                    pdfService: pdfService
                )
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
            }
        }
        .listStyle(.insetGrouped)
    }

    /// Primary row action: PDFs open in the PDF viewer; every other type with a
    /// non-empty URL opens via `openURL`. Resources with nothing to open (empty
    /// URL) fall back to Edit, since there's no destination to open. Editing is
    /// always still reachable via the "Edit" swipe action.
    private func handleTap(on resource: Resource) {
        guard !resource.url.isEmpty else {
            activeSheet = .edit(resource)
            return
        }

        if resource.type == .pdf {
            resourceForPDFViewing = resource
        } else if let url = URL(string: resource.url) {
            openURL(url)
        } else {
            activeSheet = .edit(resource)
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
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(resource.title)
                    .font(.headline)
                Spacer()
                Text(resource.type.label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 6) {
                if !resource.url.isEmpty {
                    Label("Link", systemImage: "link")
                }
                if !resource.notes.isEmpty {
                    Text(resource.notes)
                        .lineLimit(1)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(resource.title). \(resource.type.label)." +
            (resource.url.isEmpty ? "" : " Has a link.") +
            (resource.notes.isEmpty ? "" : " \(resource.notes).")
        )
    }
}
