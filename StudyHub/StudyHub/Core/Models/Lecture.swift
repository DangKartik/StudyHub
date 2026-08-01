import Foundation
import SwiftData

@Model
final class Lecture {
    var id: UUID = UUID()
    var title: String = ""
    var topic: String = ""
    var date: Date = Date.now
    var startTime: Date = Date.now
    var endTime: Date = Date.now
    var location: String = ""
    var summary: String = ""
    var notes: String = ""
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now

    var course: Course?

    @Relationship(deleteRule: .cascade, inverse: \ActiveRecallQuestion.lecture)
    var activeRecallQuestions: [ActiveRecallQuestion] = []

    @Relationship(deleteRule: .cascade, inverse: \Attachment.lecture)
    var attachments: [Attachment] = []

    @Relationship(deleteRule: .nullify, inverse: \Flashcard.lecture)
    var referencedFlashcards: [Flashcard] = []

    @Relationship(deleteRule: .cascade, inverse: \Note.lecture)
    var noteEntries: [Note] = []

    @Relationship(deleteRule: .cascade)
    var calendarEventReference: CalendarEventReference?

    /// Phase 4.3 (DECISION-037) — `.nullify`, matching `Course.studySessions`.
    @Relationship(deleteRule: .nullify, inverse: \StudySession.lecture)
    var studySessions: [StudySession] = []

    init(
        id: UUID = UUID(),
        title: String,
        topic: String = "",
        date: Date,
        startTime: Date,
        endTime: Date,
        location: String = "",
        summary: String = "",
        notes: String = "",
        createdAt: Date = Date.now,
        updatedAt: Date = Date.now
    ) {
        self.id = id
        self.title = title
        self.topic = topic
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
        self.summary = summary
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
