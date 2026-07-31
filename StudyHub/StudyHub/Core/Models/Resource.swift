import Foundation
import SwiftData

@Model
final class Resource {
    var id: UUID = UUID()
    var title: String = ""
    var type: ResourceType = ResourceType.website
    var url: String = ""
    var notes: String = ""
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now

    /// Serialized `PKDrawing.dataRepresentation()` for this resource's PDF
    /// markup — see `Attachment.markupData` for the full rationale (same
    /// storage shape, since Resources are the one PDF owner that doesn't go
    /// through `Attachment`).
    @Attribute(.externalStorage) var markupData: Data?

    var course: Course?

    init(
        id: UUID = UUID(),
        title: String,
        type: ResourceType,
        url: String = "",
        notes: String = "",
        createdAt: Date = Date.now,
        updatedAt: Date = Date.now,
        markupData: Data? = nil
    ) {
        self.id = id
        self.title = title
        self.type = type
        self.url = url
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.markupData = markupData
    }
}
