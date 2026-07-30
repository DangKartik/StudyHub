import SwiftUI

struct SemesterListView: View {
    @State private var viewModel: SemesterViewModel
    @State private var activeSheet: SemesterSheet?

    init(appState: AppState, semesterRepository: any SemesterRepositoryProtocol) {
        _viewModel = State(wrappedValue: SemesterViewModel(
            appState: appState,
            semesterRepository: semesterRepository
        ))
    }

    var body: some View {
        Group {
            if viewModel.activeSemester == nil && viewModel.otherSemesters.isEmpty && viewModel.archivedSemesters.isEmpty {
                StudyHubEmptyState(
                    icon: "calendar.badge.plus",
                    title: "No Semesters Yet",
                    message: "Create your first semester to start organizing your academics."
                )
            } else {
                list
            }
        }
        .navigationTitle("Semesters")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    activeSheet = .create
                } label: {
                    Label("Add Semester", systemImage: "plus")
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .create:
                SemesterFormView(viewModel: viewModel, semester: nil)
            case .edit(let semester):
                SemesterFormView(viewModel: viewModel, semester: semester)
            }
        }
        .onAppear {
            viewModel.loadSemesters()
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

            if let active = viewModel.activeSemester {
                Section("Active Semester") {
                    SemesterRowView(semester: active, isActive: true)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            activeSheet = .edit(active)
                        }
                        .accessibilityAddTraits(.isButton)
                        .swipeActions(edge: .trailing) {
                            Button("Archive", systemImage: "archivebox") {
                                withAnimation {
                                    viewModel.archive(active)
                                }
                            }
                            .tint(.orange)
                        }
                }
            }

            if !viewModel.otherSemesters.isEmpty {
                Section("Other Semesters") {
                    ForEach(viewModel.otherSemesters, id: \.id) { semester in
                        SemesterRowView(
                            semester: semester,
                            isActive: false,
                            onSetActive: {
                                withAnimation {
                                    viewModel.setActive(semester)
                                }
                            }
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            activeSheet = .edit(semester)
                        }
                        .accessibilityAddTraits(.isButton)
                        .swipeActions(edge: .trailing) {
                            Button("Archive", systemImage: "archivebox") {
                                withAnimation {
                                    viewModel.archive(semester)
                                }
                            }
                            .tint(.orange)

                            Button("Set Active", systemImage: "checkmark.circle") {
                                withAnimation {
                                    viewModel.setActive(semester)
                                }
                            }
                            .tint(.blue)
                        }
                    }
                }
            }

            if !viewModel.archivedSemesters.isEmpty {
                Section("Archived") {
                    ForEach(viewModel.archivedSemesters, id: \.id) { semester in
                        SemesterRowView(semester: semester, isActive: false, isArchived: true)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                activeSheet = .edit(semester)
                            }
                            .accessibilityAddTraits(.isButton)
                            .swipeActions(edge: .trailing) {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    withAnimation {
                                        viewModel.deleteSemester(semester)
                                    }
                                }

                                Button("Unarchive", systemImage: "arrow.uturn.backward") {
                                    withAnimation {
                                        viewModel.unarchive(semester)
                                    }
                                }
                                .tint(.blue)
                            }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

private enum SemesterSheet: Identifiable {
    case create
    case edit(Semester)

    var id: String {
        switch self {
        case .create: return "create"
        case .edit(let semester): return semester.id.uuidString
        }
    }
}

private struct SemesterRowView: View {
    let semester: Semester
    let isActive: Bool
    var isArchived: Bool = false
    var onSetActive: (() -> Void)? = nil

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(semester.name)
                        .font(.headline)
                    if isActive {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.blue)
                            .accessibilityHidden(true)
                    }
                }
                Text(dateRangeText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                "\(semester.name) semester." + (isActive ? " Current semester." : isArchived ? " Archived." : "")
            )

            Spacer()

            if isActive {
                Text("Current")
                    .font(.caption)
                    .foregroundStyle(.blue)
            } else if isArchived {
                Text("Archived")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else if let onSetActive {
                Button("Set Active", action: onSetActive)
                    .buttonStyle(.bordered)
                    .font(.caption)
                    .accessibilityHint("Sets \(semester.name) as the active semester.")
            }
        }
    }

    private var dateRangeText: String {
        "\(semester.startDate.formatted(date: .abbreviated, time: .omitted)) – " +
        "\(semester.endDate.formatted(date: .abbreviated, time: .omitted))"
    }
}
