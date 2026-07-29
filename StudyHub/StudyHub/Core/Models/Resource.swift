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

    var course: Course?

    init(
        id: UUID = UUID(),
        title: String,
        type: ResourceType,
        url: String = "",
        notes: String = "",
        createdAt: Date = Date.now,
        updatedAt: Date = Date.now
    ) {
        self.id = id
        self.title = title
        self.type = type
        self.url = url
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
