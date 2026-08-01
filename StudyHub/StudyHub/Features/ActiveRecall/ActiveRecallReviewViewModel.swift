import Foundation

/// Drives a single review pass over a fixed set of questions (Phase 4.2).
/// Rating only records the rating — `difficulty`/`lastReviewed`/
/// `reviewCount` per DECISION-035 — and advances to the next question. No
/// scheduling/spaced-repetition behavior is implemented here; that's a
/// later, separate phase. Mirrors `FlashcardReviewViewModel`.
@MainActor
@Observable
final class ActiveRecallReviewViewModel {
    private let activeRecallRepository: any ActiveRecallRepositoryProtocol
    /// Phase 4.3 (Study Mode) — invoked once per successful rating, so an
    /// embedding Study Session can tally "Questions answered" live.
    private let onRate: (() -> Void)?

    private(set) var questions: [ActiveRecallQuestion]
    private(set) var currentIndex = 0
    private(set) var loadError: StudyHubError?

    init(questions: [ActiveRecallQuestion], activeRecallRepository: any ActiveRecallRepositoryProtocol, onRate: (() -> Void)? = nil) {
        self.questions = questions.shuffled()
        self.activeRecallRepository = activeRecallRepository
        self.onRate = onRate
    }

    var currentQuestion: ActiveRecallQuestion? {
        questions.indices.contains(currentIndex) ? questions[currentIndex] : nil
    }

    var isFinished: Bool {
        currentIndex >= questions.count
    }

    var progressText: String {
        "\(min(currentIndex + 1, questions.count)) of \(questions.count)"
    }

    /// Reshuffles and starts over — used by the completion screen's "Review
    /// Again" action.
    func restart() {
        questions.shuffle()
        currentIndex = 0
    }

    func rate(_ rating: RecallRating) {
        guard let question = currentQuestion else { return }

        question.difficulty = rating.rawValue
        question.lastReviewed = .now
        question.reviewCount += 1
        question.updatedAt = .now

        do {
            try activeRecallRepository.save()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }

        currentIndex += 1
        onRate?()
    }
}
