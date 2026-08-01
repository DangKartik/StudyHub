import Foundation
import SwiftData

@Model
final class ActiveRecallQuestion {
    var id: UUID = UUID()
    var question: String = ""
    var answer: String = ""
    var questionType: QuestionType = QuestionType.questionAnswer
    var difficulty: Int = 0
    var lastReviewed: Date?
    var nextReviewDate: Date?
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now

    /// Direct Course ownership (Phase 4.2, DECISION-036) — a question can
    /// attach to a Course with no specific Lecture, mirroring
    /// `Flashcard.course`/`Flashcard.lecture` exactly. Reverses DECISION-027's
    /// original Lecture-only stance; see DECISION-036 for why.
    var course: Course?
    var lecture: Lecture?

    var note: Note?
    var flashcard: Flashcard?

    /// Filterable in the Active Recall library (Phase 4.2).
    var tags: [String] = []

    /// Phase 4.2 — incremented on every Review Mode rating, alongside the
    /// already-existing `difficulty`/`lastReviewed` (dormant since Phase 2,
    /// same as Flashcard's equivalents).
    var reviewCount: Int = 0

    init(
        id: UUID = UUID(),
        question: String,
        answer: String,
        questionType: QuestionType = .questionAnswer,
        tags: [String] = [],
        difficulty: Int = 0,
        lastReviewed: Date? = nil,
        nextReviewDate: Date? = nil,
        createdAt: Date = Date.now,
        updatedAt: Date = Date.now
    ) {
        self.id = id
        self.question = question
        self.answer = answer
        self.questionType = questionType
        self.tags = tags
        self.difficulty = difficulty
        self.lastReviewed = lastReviewed
        self.nextReviewDate = nextReviewDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
