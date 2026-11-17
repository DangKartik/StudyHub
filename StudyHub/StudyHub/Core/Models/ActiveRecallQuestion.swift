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

    /// Direct Course ownership — a question can
    /// attach to a Course with no specific Lecture, mirroring
    /// `Flashcard.course`/`Flashcard.lecture` exactly.
    var course: Course?
    var lecture: Lecture?

    var note: Note?
    var flashcard: Flashcard?

    /// Filterable in the Active Recall library.
    var tags: [String] = []

    /// Incremented on every Review Mode rating, alongside the
    /// already-existing `difficulty`/`lastReviewed`, same as
    /// Flashcard's equivalents.
    var reviewCount: Int = 0

    /// SM-2 scheduling state — mirrors
    /// `Flashcard.easeFactor`/`.interval`/`.repetitionCount` exactly, which
    /// already existed there.
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
