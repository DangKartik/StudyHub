import SwiftUI

/// Question -> think -> reveal answer -> self-grade (Phase 4.2). Only the
/// rating is saved; no scheduling is implemented. Mirrors
/// `FlashcardReviewView`, with a 4-level rating (Again/Hard/Good/Easy)
/// instead of 3.
struct ActiveRecallReviewView: View {
    @State private var viewModel: ActiveRecallReviewViewModel
    @State private var isRevealed = false
    @Environment(\.dismiss) private var dismiss

    init(questions: [ActiveRecallQuestion], activeRecallRepository: any ActiveRecallRepositoryProtocol, onRate: (() -> Void)? = nil) {
        _viewModel = State(wrappedValue: ActiveRecallReviewViewModel(questions: questions, activeRecallRepository: activeRecallRepository, onRate: onRate))
    }

    var body: some View {
        NavigationStack {
            Group {
                if let recallQuestion = viewModel.currentQuestion {
                    reviewContent(for: recallQuestion)
                } else {
                    completionState
                }
            }
            .navigationTitle("Active Recall")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func reviewContent(for recallQuestion: ActiveRecallQuestion) -> some View {
        VStack(spacing: 28) {
            Text(viewModel.progressText)
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            questionCard(recallQuestion)

            if isRevealed {
                ratingButtons
            } else {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isRevealed = true
                    }
                } label: {
                    Text("Reveal Answer")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
    }

    /// Clean answer reveal: the question stays visible, the answer simply
    /// fades/slides in below it — no flip gimmick, since a Question/Answer
    /// pair (unlike a flashcard's front/back) reads better shown together.
    @ViewBuilder
    private func questionCard(_ recallQuestion: ActiveRecallQuestion) -> some View {
        VStack(spacing: 16) {
            Text("Question")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(recallQuestion.question)
                .font(.title2)
                .multilineTextAlignment(.center)

            if isRevealed {
                Divider()
                    .padding(.vertical, 4)
                Text("Answer")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(recallQuestion.answer)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, minHeight: 260)
        .background(.background, in: RoundedRectangle(cornerRadius: StudyHubMetrics.flipCardCornerRadius))
        .overlay(RoundedRectangle(cornerRadius: StudyHubMetrics.flipCardCornerRadius).stroke(.separator, lineWidth: 1))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    }

    private var ratingButtons: some View {
        HStack(spacing: 10) {
            ratingButton(.again, icon: "arrow.uturn.backward", color: .red)
            ratingButton(.hard, icon: "tortoise.fill", color: .orange)
            ratingButton(.good, icon: "checkmark", color: .blue)
            ratingButton(.easy, icon: "hare.fill", color: .green)
        }
    }

    /// Icon-over-label, matching Flashcards' review buttons — same
    /// tortoise/hare pairing for Hard/Easy.
    private func ratingButton(_ rating: RecallRating, icon: String, color: Color) -> some View {
        Button {
            viewModel.rate(rating)
            isRevealed = false
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                Text(rating.label)
                    .font(.subheadline.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .tint(color)
    }

    private var completionState: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)
                .accessibilityHidden(true)
            Text("Review Complete")
                .font(.title2)
                .fontWeight(.bold)
            Text("You reviewed \(viewModel.questions.count) question\(viewModel.questions.count == 1 ? "" : "s").")
                .foregroundStyle(.secondary)

            VStack(spacing: 10) {
                Button("Review Again") {
                    viewModel.restart()
                    isRevealed = false
                }
                .buttonStyle(.borderedProminent)

                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
    }
}
