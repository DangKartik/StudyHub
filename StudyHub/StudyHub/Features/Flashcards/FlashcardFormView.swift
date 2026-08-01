import SwiftUI

struct FlashcardFormView: View {
    let viewModel: FlashcardsViewModel
    let flashcard: Flashcard?

    @Environment(\.dismiss) private var dismiss

    @State private var front: String = ""
    @State private var back: String = ""
    @State private var selectedLecture: Lecture?
    @State private var selectedNote: Note?
    @State private var tags: [String] = []
    @State private var newTagText: String = ""

    private var isEditing: Bool {
        flashcard != nil
    }

    private var canSave: Bool {
        !front.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !back.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// The card's Course — checked in priority order: a Lecture just picked
    /// in this form, then the Course/Lecture the card being *edited*
    /// already actually has, then (for new cards) the screen's own scope.
    /// Falling back only to `viewModel.resolvedCourse` was the bug: that's
    /// `nil` whenever this form is opened from the global Flashcards list
    /// (Scope.global has no course), which made every edit opened from
    /// there show "Course: None" and hide the Note picker, even though the
    /// card itself had a real course/lecture/note all along.
    private var resolvedCourse: Course? {
        selectedLecture?.course ?? flashcard?.course ?? flashcard?.lecture?.course ?? viewModel.resolvedCourse
    }

    /// Lectures for the Lecture picker — read directly from
    /// `resolvedCourse`'s own relationship rather than
    /// `viewModel.availableLectures` (which only ever returns non-empty for
    /// Course scope). That mismatch was the second half of the same bug:
    /// editing a card from the global list made the Lecture picker's option
    /// list empty, so even though `selectedLecture` held the card's real
    /// Lecture, the picker had nothing matching to display it against.
    private var availableLectures: [Lecture] {
        resolvedCourse?.lectures.sorted { $0.date < $1.date } ?? []
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

                Section("Course") {
                    Text(resolvedCourse?.name ?? "None")
                        .foregroundStyle(.secondary)
                }

                Section("Lecture") {
                    Picker("Lecture", selection: $selectedLecture) {
                        Text("None").tag(nil as Lecture?)
                        ForEach(availableLectures, id: \.id) { lecture in
                            Text(lecture.topic).tag(Optional(lecture))
                        }
                    }
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
                }

                tagsSection
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
                                lecture: selectedLecture,
                                tags: tags,
                                note: selectedNote
                            )
                        } else {
                            viewModel.createFlashcard(
                                front: front,
                                back: back,
                                lecture: selectedLecture,
                                tags: tags,
                                note: selectedNote
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
                    selectedNote = flashcard.note
                    tags = flashcard.tags
                }
            }
        }
    }

    @ViewBuilder
    private var tagsSection: some View {
        Section("Tags") {
            if !tags.isEmpty {
                FlashcardTagFlowLayout(spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
                        FlashcardTagChip(text: tag, onTap: { beginEditingTag(tag) }, onRemove: { removeTag(tag) })
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
    /// of an already-added tag before appending — mirrors NoteFormView.
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

/// Editable tag chip — mirrors `NoteFormView`'s `NoteTagChip`. Kept as a
/// separate, Flashcards-scoped copy rather than a shared component, same
/// pattern this codebase already uses for read-only row chips
/// (`NoteRowTagChip` vs `NoteTagChip`).
private struct FlashcardTagChip: View {
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
private struct FlashcardTagFlowLayout: Layout {
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
