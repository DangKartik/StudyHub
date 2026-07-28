import Foundation
import SwiftData

@Model
final class Exam {
    var id: UUID = UUID()
    var title: String = ""
    var date: Date = Date.now
    var location: String = ""
    var weight: Double = 0
    var duration: TimeInterval = 0
    var notes: String = ""

    var course: Course?

    @Relationship(deleteRule: .cascade)
    var calendarEventReference: CalendarEventReference?

    init(
        id: UUID = UUID(),
        title: String,
        date: Date,
        location: String = "",
        weight: Double = 0,
        duration: TimeInterval = 0,
        notes: String = ""
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.location = location
        self.weight = weight
        self.duration = duration
        self.notes = notes
    }
}
