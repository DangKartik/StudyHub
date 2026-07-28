import Foundation
import SwiftData

@Model
final class Quote {
    var id: UUID = UUID()
    var text: String = ""
    var hasBeenShown: Bool = false
    var lastShown: Date?
    var createdAt: Date = Date.now

    init(
        id: UUID = UUID(),
        text: String,
        hasBeenShown: Bool = false,
        lastShown: Date? = nil,
        createdAt: Date = Date.now
    ) {
        self.id = id
        self.text = text
        self.hasBeenShown = hasBeenShown
        self.lastShown = lastShown
        self.createdAt = createdAt
    }
}
