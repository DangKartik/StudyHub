import Foundation
import SwiftData

@Model
final class Semester {
    var id: UUID = UUID()
    var name: String = ""
    var startDate: Date = Date.now
    var endDate: Date = Date.now
    var color: String = ""
    var isArchived: Bool = false
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now

    @Relationship(deleteRule: .cascade, inverse: \Course.semester)
    var courses: [Course] = []

    @Relationship(deleteRule: .cascade, inverse: \StudySession.semester)
    var studySessions: [StudySession] = []

    @Relationship(deleteRule: .cascade, inverse: \StatisticsSnapshot.semester)
    var statisticsSnapshots: [StatisticsSnapshot] = []

    init(
        id: UUID = UUID(),
        name: String,
        startDate: Date,
        endDate: Date,
        color: String,
        isArchived: Bool = false,
        createdAt: Date = Date.now,
        updatedAt: Date = Date.now
    ) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.color = color
        self.isArchived = isArchived
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
