import SwiftUI

struct AssignmentFormView: View {
    let viewModel: AssignmentsViewModel
    let assignment: Assignment?

    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var dueDate: Date = .now
    @State private var dueTime: Date = AssignmentFormView.defaultDueTime
    @State private var priority: Priority = .medium
    @State private var status: AssignmentStatus = .notStarted
    @State private var assignmentDescription: String = ""
    @State private var estimatedHours: Double = 0

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
                Section("Assignment") {
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
                }

                Section("Status") {
                    Picker("Status", selection: $status) {
                        ForEach(Self.selectableStatuses, id: \.self) { status in
                            Text(status.label).tag(status)
                        }
                    }
                }

                Section("Description") {
                    TextField("Description", text: $assignmentDescription, axis: .vertical)
                        .lineLimit(3...6)
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
                                estimatedHours: estimatedHours
                            )
                        }
                        dismiss()
                    }
                    .disabled(!canSave)
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
}
