import Foundation
import SwiftData

@Model
final class Flashcard {
    var id: UUID = UUID()
    var front: String = ""
    var back: String = ""
    var image: String?
    var tags: [String] = []
    var difficulty: Int = 0
    var nextReviewDate: Date?
    var lastReviewed: Date?
    var reviewCount: Int = 0
    var easeFactor: Double = 2.5
    var interval: Double = 0
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now

    var course: Course?
    var lecture: Lecture?
    /// Phase 4.1 (DECISION-034) — optional link to the Note this card was
    /// derived from, if any. Inverse: `Note.linkedFlashcards`, `.nullify`.
    var note: Note?

    /// Active Recall questions derived from this Flashcard (Phase 4.2,
    /// DECISION-035) — completes the Question -> Flashcard -> Note -> Course
    /// chain without Flashcard needing to know about ActiveRecallQuestion
    /// directly (the relationship is declared, with its `.nullify` delete
    /// rule, on `ActiveRecallQuestion.flashcard`'s inverse).
    @Relationship(deleteRule: .nullify, inverse: \ActiveRecallQuestion.flashcard)
    var linkedActiveRecallQuestions: [ActiveRecallQuestion] = []

    init(
        id: UUID = UUID(),
        front: String,
        back: String,
        image: String? = nil,
        tags: [String] = [],
        difficulty: Int = 0,
        nextReviewDate: Date? = nil,
        lastReviewed: Date? = nil,
        reviewCount: Int = 0,
        easeFactor: Double = 2.5,
        interval: Double = 0,
        createdAt: Date = Date.now,
        updatedAt: Date = Date.now
    ) {
        self.id = id
        self.front = front
        self.back = back
        self.image = image
        self.tags = tags
        self.difficulty = difficulty
        self.nextReviewDate = nextReviewDate
        self.lastReviewed = lastReviewed
        self.reviewCount = reviewCount
        self.easeFactor = easeFactor
        self.interval = interval
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
