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

    /// SM-2 scheduling state (Phase 4.4, DECISION-038) — mirrors
    /// `Flashcard.easeFactor`/`.interval`/`.repetitionCount` exactly, which
    /// already existed there from Phase 2 but were never added here.
    /// `repetitionCount` is the SM-2 streak (resets on "Again"), distinct
    /// from `reviewCount` (a lifetime total that never resets).
    var easeFactor: Double = 2.5
    var interval: Double = 0
    var repetitionCount: Int = 0

    init(
        id: UUID = UUID(),
        question: String,
        answer: String,
        questionType: QuestionType = .questionAnswer,
        tags: [String] = [],
        difficulty: Int = 0,
        lastReviewed: Date? = nil,
        nextReviewDate: Date? = nil,
        easeFactor: Double = 2.5,
        interval: Double = 0,
        repetitionCount: Int = 0,
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
        self.easeFactor = easeFactor
        self.interval = interval
        self.repetitionCount = repetitionCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
