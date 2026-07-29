import SwiftUI

struct FlashcardFormView: View {
    let viewModel: FlashcardsViewModel
    let flashcard: Flashcard?

    @Environment(\.dismiss) private var dismiss

    @State private var front: String = ""
    @State private var back: String = ""
    @State private var selectedLecture: Lecture?

    private var isEditing: Bool {
        flashcard != nil
    }

    private var canSave: Bool {
        !front.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !back.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Front") {
                    TextEditor(text: $front)
                        .frame(minHeight: 100)
                }

                Section("Back") {
                    TextEditor(text: $back)
                        .frame(minHeight: 100)
                }

                Section("Lecture") {
                    Picker("Lecture", selection: $selectedLecture) {
                        Text("None").tag(nil as Lecture?)
                        ForEach(viewModel.availableLectures, id: \.id) { lecture in
                            Text(lecture.topic).tag(Optional(lecture))
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Flashcard" : "New Flashcard")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let flashcard {
                            viewModel.updateFlashcard(
                                flashcard,
                                front: front,
                                back: back,
                                lecture: selectedLecture
                            )
                        } else {
                            viewModel.createFlashcard(
                                front: front,
                                back: back,
                                lecture: selectedLecture
                            )
                        }
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                if let flashcard {
                    front = flashcard.front
                    back = flashcard.back
                    selectedLecture = flashcard.lecture
                }
            }
        }
    }
}
