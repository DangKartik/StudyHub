import Foundation
import SwiftData

@Model
final class Note {
    var id: UUID = UUID()
    var title: String = ""
    var body: String = ""
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now

    var course: Course?
    var lecture: Lecture?
    var reading: Reading?

    /// Filterable/displayable in the global Notes list (Phase 3.1); no tag
    /// editor exists yet in NoteFormView.
    var tags: [String] = []

    /// Phase 3.1 foundation field — no UI sets this yet, reserved for a future
    /// PDF-linking phase. See DECISION-031.
    var sourcePage: Int?

    @Relationship(deleteRule: .cascade, inverse: \Attachment.note)
    var attachments: [Attachment] = []

    init(
        id: UUID = UUID(),
        title: String,
        body: String = "",
        createdAt: Date = Date.now,
        updatedAt: Date = Date.now
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
