import Foundation
import SwiftData

@Model
final class Quiz {
    var id: UUID = UUID()
    var title: String = ""
    var date: Date = Date.now
    var weight: Double = 0
    var score: Double?
    var maximumScore: Double = 100
    var notes: String = ""

    var course: Course?

    init(
        id: UUID = UUID(),
        title: String,
        date: Date,
        weight: Double = 0,
        score: Double? = nil,
        maximumScore: Double = 100,
        notes: String = ""
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.weight = weight
        self.score = score
        self.maximumScore = maximumScore
        self.notes = notes
    }
}
