import Foundation
import SwiftData

@Model
final class Reading {
    var id: UUID = UUID()
    var title: String = ""
    var author: String = ""
    var notes: String = ""
    var dueDate: Date?
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now

    var course: Course?

    @Relationship(deleteRule: .cascade, inverse: \Attachment.reading)
    var attachments: [Attachment] = []

    /// .nullify, not .cascade — deleting a Reading must not destroy notes the
    /// user wrote about it. See DECISION-032.
    @Relationship(deleteRule: .nullify, inverse: \Note.reading)
    var noteEntries: [Note] = []

    init(
        id: UUID = UUID(),
        title: String,
        author: String = "",
        notes: String = "",
        dueDate: Date? = nil,
        createdAt: Date = Date.now,
        updatedAt: Date = Date.now
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.notes = notes
        self.dueDate = dueDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
