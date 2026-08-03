import SwiftUI

struct AssignmentListView: View {
    let bookmarkRepository: any BookmarkRepositoryProtocol
    let pdfProgressRepository: any PDFProgressRepositoryProtocol
    let pdfService: any PDFServiceProtocol

    @State private var viewModel: AssignmentsViewModel
    @State private var activeSheet: AssignmentSheet?

    init(
        course: Course,
        assignmentRepository: any AssignmentRepositoryProtocol,
        bookmarkRepository: any BookmarkRepositoryProtocol,
        pdfProgressRepository: any PDFProgressRepositoryProtocol,
        pdfService: any PDFServiceProtocol,
        notificationManager: any NotificationSchedulingProtocol,
        calendarSyncService: any CalendarSyncServiceProtocol,
        calendarRepository: any CalendarRepositoryProtocol,
        userPreferences: UserPreferences
    ) {
        self.bookmarkRepository = bookmarkRepository
        self.pdfProgressRepository = pdfProgressRepository
        self.pdfService = pdfService
        _viewModel = State(wrappedValue: AssignmentsViewModel(
            course: course,
            assignmentRepository: assignmentRepository,
            notificationManager: notificationManager,
            calendarSyncService: calendarSyncService,
            calendarRepository: calendarRepository,
            userPreferences: userPreferences
        ))
    }

    var body: some View {
        Group {
            if viewModel.assignments.isEmpty {
                StudyHubEmptyState(
                    icon: "checklist",
                    title: "No Assignments Yet",
                    message: "Add assignments to track your coursework.",
                    actionTitle: "Add Assignment"
                ) {
                    activeSheet = .create
                }
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
                AssignmentFormView(
                    viewModel: viewModel,
                    assignment: nil,
                    bookmarkRepository: bookmarkRepository,
                    pdfProgressRepository: pdfProgressRepository,
                    pdfService: pdfService
                )
            case .edit(let assignment):
                AssignmentFormView(
                    viewModel: viewModel,
                    assignment: assignment,
                    bookmarkRepository: bookmarkRepository,
                    pdfProgressRepository: pdfProgressRepository,
                    pdfService: pdfService
                )
            }
        }
        .onAppear {
            viewModel.loadAssignments()
            viewModel.reconcileReminderCompletion()
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
                Section {
                    ForEach(viewModel.activeAssignments, id: \.id) { assignment in
                        AssignmentRowView(assignment: assignment)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                activeSheet = .edit(assignment)
                            }
                            .accessibilityAddTraits(.isButton)
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
                            .contextMenu {
                                Button("Complete", systemImage: "checkmark") {
                                    withAnimation {
                                        viewModel.completeAssignment(assignment)
                                    }
                                }
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    viewModel.deleteAssignment(assignment)
                                }
                            }
                    }
                } header: {
                    ListSectionHeaderLabel(title: "Active Assignments", icon: "checklist", tint: .blue)
                }
            }

            if !viewModel.completedAssignments.isEmpty {
                Section {
                    ForEach(viewModel.completedAssignments, id: \.id) { assignment in
                        AssignmentRowView(assignment: assignment)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                activeSheet = .edit(assignment)
                            }
                            .accessibilityAddTraits(.isButton)
                            .swipeActions(edge: .trailing) {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    viewModel.deleteAssignment(assignment)
                                }
                            }
                            .contextMenu {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    viewModel.deleteAssignment(assignment)
                                }
                            }
                    }
                } header: {
                    ListSectionHeaderLabel(title: "Completed Assignments", icon: "checkmark.circle.fill", tint: .green)
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

    private var isCompleted: Bool {
        assignment.status == .completed
    }

    private var isOverdue: Bool {
        !isCompleted && assignment.dueDate < .now
    }

    var body: some View {
        HStack(spacing: 12) {
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(assignment.title)
                    .font(.headline)
                    .strikethrough(isCompleted)
                    .foregroundStyle(isCompleted ? .secondary : .primary)

                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                    Text(assignment.dueDate.formatted(date: .abbreviated, time: .shortened))
                }
                .font(.subheadline)
                .foregroundStyle(isOverdue ? .red : .secondary)
            }

            Spacer()

            if !isCompleted {
                VStack(alignment: .trailing, spacing: 4) {
                    badge(isOverdue ? "Overdue" : assignment.priority.label, tint: isOverdue ? .red : assignment.priority.color)
                    if assignment.status != .notStarted {
                        Text(assignment.status.label)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(assignment.title). Due \(assignment.dueDate.formatted(date: .abbreviated, time: .omitted)). "
                + (isOverdue ? "Overdue. " : "\(assignment.priority.label) priority. ")
                + "\(assignment.status.label)."
        )
    }

    private func badge(_ text: String, tint: Color) -> some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, StudyHubMetrics.chipHorizontalPadding + 2)
            .padding(.vertical, StudyHubMetrics.chipVerticalPadding + 1)
            .background(tint.opacity(0.14), in: Capsule())
    }
}
