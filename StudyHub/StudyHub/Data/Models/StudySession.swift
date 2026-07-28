import Foundation
import SwiftData

@Model
final class StudySession {
    var id: UUID = UUID()
    var startTime: Date = Date.now
    var endTime: Date?
    var duration: TimeInterval = 0
    var completedPomodoros: Int = 0
    var focusScore: Double = 0
    var createdAt: Date = Date.now

    var semester: Semester?

    @Relationship(inverse: \Course.studySessions)
    var courses: [Course] = []

    var flashcardsReviewed: [Flashcard] = []

    init(
        id: UUID = UUID(),
        startTime: Date,
        endTime: Date? = nil,
        duration: TimeInterval = 0,
        completedPomodoros: Int = 0,
        focusScore: Double = 0,
        createdAt: Date = Date.now
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.completedPomodoros = completedPomodoros
        self.focusScore = focusScore
        self.createdAt = createdAt
    }
}
