import SwiftUI

/// Simple front/back review screen (Phase 4.1) — tap to flip, then rate
/// Again/Hard/Good/Easy. Rating immediately computes the card's next
/// review via SM-2 (Phase 4.4, DECISION-038).
struct FlashcardReviewView: View {
    @State private var viewModel: FlashcardReviewViewModel
    @State private var isFlipped = false
    @Environment(\.dismiss) private var dismiss

    init(cards: [Flashcard], flashcardRepository: any FlashcardRepositoryProtocol, onRate: (() -> Void)? = nil) {
        _viewModel = State(wrappedValue: FlashcardReviewViewModel(cards: cards, flashcardRepository: flashcardRepository, onRate: onRate))
    }

    var body: some View {
        NavigationStack {
            Group {
                if let card = viewModel.currentCard {
                    reviewContent(for: card)
                } else {
                    completionState
                }
            }
            .navigationTitle("Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func reviewContent(for card: Flashcard) -> some View {
        VStack(spacing: 28) {
            Text(viewModel.progressText)
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            cardFace(card)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        isFlipped.toggle()
                    }
                }

            if isFlipped {
                ratingButtons
            } else {
                Text("Tap the card to reveal the answer")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
    }

    /// Standard SwiftUI flip-card recipe: two independently-rotated faces
    /// cross-fading via opacity as they rotate past 90°, so the back face's
    /// (mirrored, if visible) text is never actually shown mid-flip.
    @ViewBuilder
    private func cardFace(_ card: Flashcard) -> some View {
        ZStack {
            face(label: "Question", text: card.front)
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                .accessibilityHidden(isFlipped)

            face(label: "Answer", text: card.back)
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
                .accessibilityHidden(!isFlipped)
        }
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(isFlipped ? "" : "Double tap to reveal the answer")
    }

    private func face(label: String, text: String) -> some View {
        VStack(spacing: 12) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(text)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(24)
        .frame(maxWidth: .infinity, minHeight: 260)
        .background(.background, in: RoundedRectangle(cornerRadius: StudyHubMetrics.flipCardCornerRadius))
        .overlay(RoundedRectangle(cornerRadius: StudyHubMetrics.flipCardCornerRadius).stroke(.separator, lineWidth: 1))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    }

    private var ratingButtons: some View {
        HStack(spacing: 10) {
            ratingButton("Again", icon: "arrow.uturn.backward", color: .red, rating: .again)
            ratingButton("Hard", icon: "tortoise.fill", color: .orange, rating: .hard)
            ratingButton("Good", icon: "checkmark", color: .blue, rating: .good)
            ratingButton("Easy", icon: "hare.fill", color: .green, rating: .easy)
        }
    }

    /// Icon-over-label instead of a bare word, and a tortoise/hare pairing
    /// for Hard/Easy specifically — reads faster at a glance than four
    /// same-shaped text buttons that only differ by color and word choice.
    private func ratingButton(_ title: String, icon: String, color: Color, rating: FlashcardRating) -> some View {
        Button {
            viewModel.rate(rating)
            isFlipped = false
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                Text(title)
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
            Text("You reviewed \(viewModel.cards.count) card\(viewModel.cards.count == 1 ? "" : "s").")
                .foregroundStyle(.secondary)

            VStack(spacing: 10) {
                Button("Review Again") {
                    viewModel.restart()
                    isFlipped = false
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
