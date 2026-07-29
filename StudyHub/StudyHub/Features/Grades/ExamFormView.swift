import SwiftUI

struct ExamFormView: View {
    let viewModel: GradesViewModel
    let exam: Exam?

    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var date: Date = .now
    @State private var location: String = ""
    @State private var weight: Double = 0
    @State private var durationMinutes: Double = 0
    @State private var notes: String = ""

    private var isEditing: Bool {
        exam != nil
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Exam") {
                    TextField("Title", text: $title)
                    StudyHubDateField(label: "Date", date: $date)
                    TextField("Location", text: $location)

                    HStack {
                        Text("Weight (%)")
                        Spacer()
                        SelectAllNumberField(value: $weight, keyboardType: .decimalPad)
                    }

                    HStack {
                        Text("Duration (minutes)")
                        Spacer()
                        SelectAllNumberField(value: $durationMinutes, keyboardType: .decimalPad)
                    }
                }

                Section("Notes") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(isEditing ? "Edit Exam" : "New Exam")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let duration = durationMinutes * 60
                        if let exam {
                            viewModel.updateExam(
                                exam,
                                title: title,
                                date: date,
                                location: location,
                                weight: weight,
                                duration: duration,
                                notes: notes
                            )
                        } else {
                            viewModel.createExam(
                                title: title,
                                date: date,
                                location: location,
                                weight: weight,
                                duration: duration,
                                notes: notes
                            )
                        }
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                if let exam {
                    title = exam.title
                    date = exam.date
                    location = exam.location
                    weight = exam.weight
                    durationMinutes = exam.duration / 60
                    notes = exam.notes
                }
            }
        }
    }
}
