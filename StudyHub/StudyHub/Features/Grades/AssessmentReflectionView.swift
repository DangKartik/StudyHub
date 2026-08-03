import SwiftUI

/// Shown once per past, un-reflected `Assessment` the next time the app is
/// opened — a lightweight personal "how did it go" note, separate from the
/// real score (which still gets entered on the assessment itself whenever
/// it's actually graded). Purely local state; `onSubmit`/`onSkip` persist.
struct AssessmentReflectionView: View {
    let assessment: Assessment
    let onSubmit: (_ rating: Int?, _ note: String) -> Void
    let onSkip: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var rating: Int?
    @State private var note: String = ""

    /// `true` when reopened from the assessment's own edit form to revisit
    /// an already-answered reflection — the cancel button reads "Cancel"
    /// there instead of "Skip", since there's nothing left to skip.
    private var isRevisiting: Bool {
        assessment.hasReflected
    }

    private var courseLabel: String {
        guard let course = assessment.course else { return "" }
        return course.name.isEmpty ? course.courseCode : course.name
    }

    init(assessment: Assessment, onSubmit: @escaping (_ rating: Int?, _ note: String) -> Void, onSkip: @escaping () -> Void) {
        self.assessment = assessment
        self.onSubmit = onSubmit
        self.onSkip = onSkip
        _rating = State(initialValue: assessment.reflectionRating)
        _note = State(initialValue: assessment.reflectionNote)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(assessment.title)
                            .font(.headline)
                        if !courseLabel.isEmpty {
                            Text(courseLabel)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Label("How did your \(assessment.kind.label.lowercased()) go?", systemImage: assessment.kind.icon)
                }

                Section("Rating") {
                    HStack(spacing: 12) {
                        ForEach(1...5, id: \.self) { value in
                            Button {
                                rating = (rating == value) ? nil : value
                            } label: {
                                Image(systemName: (rating ?? 0) >= value ? "star.fill" : "star")
                                    .font(.title2)
                                    .foregroundStyle((rating ?? 0) >= value ? .yellow : .secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Note (Optional)") {
                    TextField("Any thoughts on how it went…", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Quick Reflection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(isRevisiting ? "Cancel" : "Skip") {
                        if !isRevisiting {
                            onSkip()
                        }
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSubmit(rating, note)
                        dismiss()
                    }
                    .disabled(rating == nil && note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
