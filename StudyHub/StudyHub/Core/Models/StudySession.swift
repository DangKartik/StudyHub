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

    /// Phase 4.3 (DECISION-037) — singular, optional, matching the actual
    /// "pick one Course, optionally one Lecture" Study Mode flow. Replaces
    /// the original `courses: [Course]` many-to-many, which had zero
    /// consumers and didn't represent this shape at all.
    var course: Course?
    var lecture: Lecture?

    /// Session-scoped tallies (Phase 4.3) — StudySession orchestrates and
    /// counts, it doesn't own the reviewed content itself. Flashcard/
    /// ActiveRecallQuestion already track their own review history
    /// (reviewCount/lastReviewed/difficulty, DECISION-034/035); these are
    /// just how many of those actions happened during *this* session.
    var flashcardsReviewedCount: Int = 0
    var questionsAnsweredCount: Int = 0
    var pagesReadCount: Int = 0
    var notesOpenedCount: Int = 0

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
