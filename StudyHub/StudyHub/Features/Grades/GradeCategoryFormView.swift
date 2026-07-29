import SwiftUI

struct GradeCategoryFormView: View {
    let viewModel: GradesViewModel
    let gradeCategory: GradeCategory?

    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var weight: Double = 0
    @State private var earnedScore: Double = 0
    @State private var maximumScore: Double = 100

    private var isEditing: Bool {
        gradeCategory != nil
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Grade Category") {
                    TextField("Title", text: $title)

                    HStack {
                        Text("Weight (%)")
                        Spacer()
                        SelectAllNumberField(value: $weight, keyboardType: .decimalPad)
                    }

                    HStack {
                        Text("Earned Score")
                        Spacer()
                        SelectAllNumberField(value: $earnedScore, keyboardType: .decimalPad)
                    }

                    HStack {
                        Text("Maximum Score")
                        Spacer()
                        SelectAllNumberField(value: $maximumScore, keyboardType: .decimalPad)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Grade Category" : "New Grade Category")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let gradeCategory {
                            viewModel.updateGradeCategory(
                                gradeCategory,
                                title: title,
                                weight: weight,
                                earnedScore: earnedScore,
                                maximumScore: maximumScore
                            )
                        } else {
                            viewModel.createGradeCategory(
                                title: title,
                                weight: weight,
                                earnedScore: earnedScore,
                                maximumScore: maximumScore
                            )
                        }
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                if let gradeCategory {
                    title = gradeCategory.title
                    weight = gradeCategory.weight
                    earnedScore = gradeCategory.earnedScore
                    maximumScore = gradeCategory.maximumScore
                }
            }
        }
    }
}
