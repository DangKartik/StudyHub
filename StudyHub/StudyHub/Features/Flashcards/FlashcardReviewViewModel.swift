import Foundation

/// Drives a single review pass over a fixed set of cards.
/// Rating a card records the rating — `difficulty`/`lastReviewed`/
/// `reviewCount` — and immediately computes its next
/// review via the shared `SpacedRepetitionScheduler`, then advances to the next card.
@MainActor
@Observable
final class FlashcardReviewViewModel {
    private let flashcardRepository: any FlashcardRepositoryProtocol
    /// Study Mode hook — invoked once per successful rating, so an
    /// embedding Study Session can tally "Flashcards reviewed" live.
    private let onRate: (() -> Void)?

    private(set) var cards: [Flashcard]
    private(set) var currentIndex = 0
    private(set) var loadError: StudyHubError?

    init(cards: [Flashcard], flashcardRepository: any FlashcardRepositoryProtocol, onRate: (() -> Void)? = nil) {
        self.cards = cards.shuffled()
        self.flashcardRepository = flashcardRepository
        self.onRate = onRate
    }

    /// Reshuffles and starts over — used by the completion screen's "Review
    /// Again" action.
    func restart() {
        cards.shuffle()
        currentIndex = 0
    }

    var currentCard: Flashcard? {
        cards.indices.contains(currentIndex) ? cards[currentIndex] : nil
    }

    var isFinished: Bool {
        currentIndex >= cards.count
    }

    var progressText: String {
        "\(min(currentIndex + 1, cards.count)) of \(cards.count)"
    }

    func rate(_ rating: FlashcardRating) {
        guard let card = currentCard else { return }

        let scheduled = SpacedRepetitionScheduler.schedule(
            rating: rating.reviewGrade,
            current: .init(easeFactor: card.easeFactor, interval: card.interval, repetitionCount: card.repetitionCount)
        )

        card.difficulty = rating.rawValue
        card.lastReviewed = .now
        card.reviewCount += 1
        card.easeFactor = scheduled.easeFactor
        card.interval = scheduled.interval
        card.repetitionCount = scheduled.repetitionCount
        card.nextReviewDate = scheduled.nextReviewDate
        card.updatedAt = .now

        do {
            try flashcardRepository.save()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }

        currentIndex += 1
        onRate?()
    }
}
