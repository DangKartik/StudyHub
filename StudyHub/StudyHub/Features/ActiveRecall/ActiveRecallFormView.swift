import SwiftUI

struct ActiveRecallFormView: View {
    let viewModel: ActiveRecallViewModel
    let recallQuestion: ActiveRecallQuestion?

    @Environment(\.dismiss) private var dismiss

    @State private var question: String = ""
    @State private var answer: String = ""
    @State private var questionType: QuestionType = .questionAnswer

    private var isEditing: Bool {
        recallQuestion != nil
    }

    private var canSave: Bool {
        !question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Question") {
                    TextEditor(text: $question)
                        .frame(minHeight: 100)
                }

                Section("Answer") {
                    TextEditor(text: $answer)
                        .frame(minHeight: 100)
                }

                Section("Type") {
                    Picker("Type", selection: $questionType) {
                        ForEach(QuestionType.allCases, id: \.self) { type in
                            Text(type.label).tag(type)
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Question" : "New Question")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let recallQuestion {
                            viewModel.updateQuestion(
                                recallQuestion,
                                question: question,
                                answer: answer,
                                questionType: questionType
                            )
                        } else {
                            viewModel.createQuestion(
                                question: question,
                                answer: answer,
                                questionType: questionType
                            )
                        }
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                if let recallQuestion {
                    question = recallQuestion.question
                    answer = recallQuestion.answer
                    questionType = recallQuestion.questionType
                }
            }
        }
    }
}
