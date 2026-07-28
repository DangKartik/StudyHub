import Foundation
import SwiftData

@Model
final class Attachment {
    var id: UUID = UUID()
    var filename: String = ""
    var type: String = ""
    var url: String = ""
    var size: Int = 0
    var createdAt: Date = Date.now

    var lecture: Lecture?
    var assignment: Assignment?
    var reading: Reading?

    init(
        id: UUID = UUID(),
        filename: String,
        type: String,
        url: String,
        size: Int = 0,
        createdAt: Date = Date.now
    ) {
        self.id = id
        self.filename = filename
        self.type = type
        self.url = url
        self.size = size
        self.createdAt = createdAt
    }
}
