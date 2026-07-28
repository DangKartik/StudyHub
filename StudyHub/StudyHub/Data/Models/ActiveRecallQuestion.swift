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

    var lecture: Lecture?

    init(
        id: UUID = UUID(),
        question: String,
        answer: String,
        questionType: QuestionType = .questionAnswer,
        difficulty: Int = 0,
        lastReviewed: Date? = nil,
        nextReviewDate: Date? = nil
    ) {
        self.id = id
        self.question = question
        self.answer = answer
        self.questionType = questionType
        self.difficulty = difficulty
        self.lastReviewed = lastReviewed
        self.nextReviewDate = nextReviewDate
    }
}
