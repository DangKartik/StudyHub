import Foundation
import SwiftData

@Model
final class StatisticsSnapshot {
    var id: UUID = UUID()
    var date: Date = Date.now
    var studyHours: Double = 0
    var readingMinutes: Int = 0
    var assignmentsCompleted: Int = 0
    var flashcardsReviewed: Int = 0
    var accuracy: Double = 0

    var semester: Semester?

    init(
        id: UUID = UUID(),
        date: Date,
        studyHours: Double = 0,
        readingMinutes: Int = 0,
        assignmentsCompleted: Int = 0,
        flashcardsReviewed: Int = 0,
        accuracy: Double = 0
    ) {
        self.id = id
        self.date = date
        self.studyHours = studyHours
        self.readingMinutes = readingMinutes
        self.assignmentsCompleted = assignmentsCompleted
        self.flashcardsReviewed = flashcardsReviewed
        self.accuracy = accuracy
    }
}
