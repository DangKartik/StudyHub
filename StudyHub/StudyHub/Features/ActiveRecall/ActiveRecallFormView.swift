import SwiftUI

struct ActiveRecallFormView: View {
    let viewModel: ActiveRecallViewModel
    let recallQuestion: ActiveRecallQuestion?

    @Environment(\.dismiss) private var dismiss

    @State private var question: String = ""
    @State private var answer: String = ""
    @State private var questionType: QuestionType = .questionAnswer
    @State private var selectedLecture: Lecture?
    @State private var selectedNote: Note?
    @State private var selectedFlashcard: Flashcard?
    @State private var tags: [String] = []
    @State private var newTagText: String = ""

    private var isEditing: Bool {
        recallQuestion != nil
    }

    /// True only when creating (not editing) from Course scope — Lecture
    /// scope has an implied, fixed Lecture and shows no picker at all.
    /// Course scope shows an *optional* Lecture picker (DECISION-036):
    /// "None" attaches the question directly to the Course, exactly like
    /// Flashcard's own optional Lecture picker.
    private var showsLecturePicker: Bool {
        !isEditing && viewModel.isCreatingFromCourseScope
    }

    private var canSave: Bool {
        !question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// The question's Course — checked in priority order: the question
    /// being *edited*'s own direct Course or Lecture, a Lecture just picked
    /// when creating from Course scope, then the screen's own scope.
    /// Falling back only to `viewModel.resolvedCourse` was the exact bug
    /// found in Flashcards' form (DECISION-034 follow-up): that's `nil`
    /// whenever this form is opened from Global scope, which would show
    /// "Course: None" and hide the Note/Flashcard pickers even though the
    /// question itself has a real Course.
    private var resolvedCourse: Course? {
        recallQuestion?.course ?? recallQuestion?.lecture?.course ?? selectedLecture?.course ?? viewModel.resolvedCourse
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Question") {
                    PlaceholderTextEditor(placeholder: "What question do you want to be quizzed on?", text: $question)
                        .frame(minHeight: 100)
                }

                Section("Answer") {
                    PlaceholderTextEditor(placeholder: "What's the answer?", text: $answer)
                        .frame(minHeight: 100)
                }

                Section("Type") {
                    Picker("Type", selection: $questionType) {
                        ForEach(QuestionType.allCases, id: \.self) { type in
                            Text(type.label).tag(type)
                        }
                    }
                }

                if showsLecturePicker {
                    Section("Lecture") {
                        Picker("Lecture", selection: $selectedLecture) {
                            Text("Course Only").tag(nil as Lecture?)
                            ForEach(viewModel.availableLecturesForCreation, id: \.id) { lecture in
                                Text(lecture.topic).tag(Optional(lecture))
                            }
                        }
                    }
                }

                Section("Course") {
                    Text(resolvedCourse?.name ?? "None")
                        .foregroundStyle(.secondary)
                }

                if let resolvedCourse {
                    Section("Linked Note") {
                        Picker("Linked Note", selection: $selectedNote) {
                            Text("None").tag(nil as Note?)
                            ForEach(viewModel.availableNotes(for: resolvedCourse), id: \.id) { note in
                                Text(note.title.isEmpty ? "Untitled Note" : note.title).tag(Optional(note))
                            }
                        }
                    }

                    Section("Linked Flashcard") {
                        Picker("Linked Flashcard", selection: $selectedFlashcard) {
                            Text("None").tag(nil as Flashcard?)
                            ForEach(viewModel.availableFlashcards(for: resolvedCourse), id: \.id) { flashcard in
                                Text(flashcard.front).lineLimit(1).tag(Optional(flashcard))
                            }
                        }
                    }
                }

                tagsSection
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
                                questionType: questionType,
                                tags: tags,
                                note: selectedNote,
                                flashcard: selectedFlashcard
                            )
                        } else {
                            viewModel.createQuestion(
                                question: question,
                                answer: answer,
                                questionType: questionType,
                                tags: tags,
                                note: selectedNote,
                                flashcard: selectedFlashcard,
                                lecture: selectedLecture
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
                    selectedNote = recallQuestion.note
                    selectedFlashcard = recallQuestion.flashcard
                    tags = recallQuestion.tags
                }
            }
        }
    }

    @ViewBuilder
    private var tagsSection: some View {
        Section("Tags") {
            if !tags.isEmpty {
                ActiveRecallTagFlowLayout(spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
                        ActiveRecallTagChip(text: tag, onTap: { beginEditingTag(tag) }, onRemove: { removeTag(tag) })
                    }
                }
            }

            HStack {
                TextField("Add Tag", text: $newTagText)
                    .onSubmit(commitNewTag)
                Button(action: commitNewTag) {
                    Image(systemName: "plus.circle.fill")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.tint)
                .disabled(newTagText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    /// Trims, rejects empty input, and rejects a case-insensitive duplicate
    /// of an already-added tag before appending — mirrors NoteFormView/FlashcardFormView.
    private func commitNewTag() {
        let trimmed = newTagText.trimmingCharacters(in: .whitespacesAndNewlines)
        newTagText = ""
        guard !trimmed.isEmpty else { return }
        guard !tags.contains(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) else { return }
        tags.append(trimmed)
    }

    private func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }

    private func beginEditingTag(_ tag: String) {
        removeTag(tag)
        newTagText = tag
    }
}

/// Editable tag chip — mirrors `NoteFormView.NoteTagChip`/`FlashcardFormView.FlashcardTagChip`.
/// Kept as its own scoped copy rather than a shared component, same
/// duplication pattern this codebase already uses for these chips.
private struct ActiveRecallTagChip: View {
    let text: String
    let onTap: () -> Void
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.subheadline)
                .onTapGesture(perform: onTap)

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .foregroundStyle(Color.accentColor)
        .background(Color.accentColor.opacity(0.15), in: Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text)
        .accessibilityAction(named: "Edit", onTap)
        .accessibilityAction(named: "Remove", onRemove)
    }
}

/// Wrapping row layout for tag chips — mirrors `NoteFormView.TagFlowLayout`.
private struct ActiveRecallTagFlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var rowWidth: CGFloat = 0
        var totalHeight: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth > 0, rowWidth + spacing + size.width > maxWidth {
                totalHeight += rowHeight + spacing
                rowWidth = 0
                rowHeight = 0
            }
            rowWidth += (rowWidth > 0 ? spacing : 0) + size.width
            rowHeight = max(rowHeight, size.height)
        }
        totalHeight += rowHeight
        return CGSize(width: maxWidth.isFinite ? maxWidth : rowWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > bounds.minX, x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
