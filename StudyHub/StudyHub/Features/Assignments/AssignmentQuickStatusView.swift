import SwiftUI

/// Reached by tapping an assignment from Home's "Today"/"Upcoming
/// Assignments" cards — everything here is read-only except Status.
/// Changing the title, due date, priority, or description still requires
/// opening the full edit form from the course's own Assignments list; this
/// view exists so Home can answer "what is this assignment about" and "let
/// me mark progress" without exposing every editable field from a
/// dashboard card.
struct AssignmentQuickStatusView: View {
    let viewModel: AssignmentsViewModel
    let assignment: Assignment

    @Environment(\.dismiss) private var dismiss
    @State private var status: AssignmentStatus

    private static let selectableStatuses: [AssignmentStatus] = [.notStarted, .inProgress, .completed]

    init(viewModel: AssignmentsViewModel, assignment: Assignment) {
        self.viewModel = viewModel
        self.assignment = assignment
        _status = State(initialValue: assignment.status)
    }

    private var courseLabel: String {
        guard let course = assignment.course else { return "—" }
        return course.name.isEmpty ? course.courseCode : course.name
    }

    private var trimmedDescription: String {
        assignment.assignmentDescription.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent("Title", value: assignment.title)
                    LabeledContent("Course", value: courseLabel)
                    LabeledContent("Due", value: assignment.dueDate.formatted(date: .abbreviated, time: .shortened))
                    LabeledContent("Priority", value: assignment.priority.label)
                    if assignment.estimatedHours > 0 {
                        LabeledContent("Estimated Hours", value: String(format: "%.1f", assignment.estimatedHours))
                    }
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

                if !trimmedDescription.isEmpty {
                    Section {
                        Text(assignment.assignmentDescription)
                            .foregroundStyle(.secondary)
                    } header: {
                        Label("Description", systemImage: "text.alignleft")
                    }
                }
            }
            .navigationTitle("Assignment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.updateAssignment(
                            assignment,
                            title: assignment.title,
                            dueDate: assignment.dueDate,
                            priority: assignment.priority,
                            status: status,
                            description: assignment.assignmentDescription,
                            estimatedHours: assignment.estimatedHours
                        )
                        dismiss()
                    }
                    .disabled(status == assignment.status)
                }
            }
        }
    }
}
