import SwiftUI

struct AssignmentListView: View {
    @State private var viewModel: AssignmentsViewModel
    @State private var activeSheet: AssignmentSheet?

    init(course: Course, assignmentRepository: any AssignmentRepositoryProtocol) {
        _viewModel = State(wrappedValue: AssignmentsViewModel(
            course: course,
            assignmentRepository: assignmentRepository
        ))
    }

    var body: some View {
        Group {
            if viewModel.assignments.isEmpty {
                StudyHubEmptyState(
                    icon: "checklist",
                    title: "No Assignments Yet",
                    message: "Add assignments to track your coursework."
                )
            } else {
                list
            }
        }
        .navigationTitle("Assignments")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    activeSheet = .create
                } label: {
                    Label("Add Assignment", systemImage: "plus")
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .create:
                AssignmentFormView(viewModel: viewModel, assignment: nil)
            case .edit(let assignment):
                AssignmentFormView(viewModel: viewModel, assignment: assignment)
            }
        }
        .onAppear {
            viewModel.loadAssignments()
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

            if !viewModel.activeAssignments.isEmpty {
                Section("Active Assignments") {
                    ForEach(viewModel.activeAssignments, id: \.id) { assignment in
                        AssignmentRowView(assignment: assignment)
                            .onTapGesture {
                                activeSheet = .edit(assignment)
                            }
                            .swipeActions(edge: .trailing) {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    viewModel.deleteAssignment(assignment)
                                }

                                Button("Complete", systemImage: "checkmark") {
                                    withAnimation {
                                        viewModel.completeAssignment(assignment)
                                    }
                                }
                                .tint(.green)
                            }
                    }
                }
            }

            if !viewModel.completedAssignments.isEmpty {
                Section("Completed Assignments") {
                    ForEach(viewModel.completedAssignments, id: \.id) { assignment in
                        AssignmentRowView(assignment: assignment)
                            .onTapGesture {
                                activeSheet = .edit(assignment)
                            }
                            .swipeActions(edge: .trailing) {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    viewModel.deleteAssignment(assignment)
                                }
                            }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

private enum AssignmentSheet: Identifiable {
    case create
    case edit(Assignment)

    var id: String {
        switch self {
        case .create: return "create"
        case .edit(let assignment): return assignment.id.uuidString
        }
    }
}

private struct AssignmentRowView: View {
    let assignment: Assignment

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(assignment.title)
                    .font(.headline)
                Spacer()
                Text(assignment.priority.label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 6) {
                Text(assignment.dueDate.formatted(date: .abbreviated, time: .omitted))
                Text("· \(assignment.status.label)")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(assignment.title). Due \(assignment.dueDate.formatted(date: .abbreviated, time: .omitted)). " +
            "\(assignment.priority.label) priority. \(assignment.status.label)."
        )
    }
}
