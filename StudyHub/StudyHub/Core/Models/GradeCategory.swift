import Foundation
import SwiftData

@Model
final class GradeCategory {
    var id: UUID = UUID()
    var title: String = ""
    var weight: Double = 0
    var earnedScore: Double = 0
    var maximumScore: Double = 100

    var course: Course?

    init(
        id: UUID = UUID(),
        title: String,
        weight: Double,
        earnedScore: Double = 0,
        maximumScore: Double = 100
    ) {
        self.id = id
        self.title = title
        self.weight = weight
        self.earnedScore = earnedScore
        self.maximumScore = maximumScore
    }
}
