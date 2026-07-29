import SwiftUI

struct QuizFormView: View {
    let viewModel: GradesViewModel
    let quiz: Quiz?

    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var date: Date = .now
    @State private var weight: Double = 0
    @State private var isGraded: Bool = false
    @State private var score: Double = 0
    @State private var maximumScore: Double = 100
    @State private var notes: String = ""

    private var isEditing: Bool {
        quiz != nil
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Quiz") {
                    TextField("Title", text: $title)
                    StudyHubDateField(label: "Date", date: $date)

                    HStack {
                        Text("Weight (%)")
                        Spacer()
                        SelectAllNumberField(value: $weight, keyboardType: .decimalPad)
                    }
                }

                Section("Score") {
                    Toggle("Graded", isOn: $isGraded)

                    if isGraded {
                        HStack {
                            Text("Score")
                            Spacer()
                            SelectAllNumberField(value: $score, keyboardType: .decimalPad)
                        }
                    }

                    HStack {
                        Text("Maximum Score")
                        Spacer()
                        SelectAllNumberField(value: $maximumScore, keyboardType: .decimalPad)
                    }
                }

                Section("Notes") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(isEditing ? "Edit Quiz" : "New Quiz")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let quiz {
                            viewModel.updateQuiz(
                                quiz,
                                title: title,
                                date: date,
                                weight: weight,
                                score: isGraded ? score : nil,
                                maximumScore: maximumScore,
                                notes: notes
                            )
                        } else {
                            viewModel.createQuiz(
                                title: title,
                                date: date,
                                weight: weight,
                                score: isGraded ? score : nil,
                                maximumScore: maximumScore,
                                notes: notes
                            )
                        }
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                if let quiz {
                    title = quiz.title
                    date = quiz.date
                    weight = quiz.weight
                    maximumScore = quiz.maximumScore
                    notes = quiz.notes
                    if let existingScore = quiz.score {
                        isGraded = true
                        score = existingScore
                    }
                }
            }
        }
    }
}
