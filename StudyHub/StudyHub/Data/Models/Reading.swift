import Foundation
import SwiftData

@Model
final class Reading {
    var id: UUID = UUID()
    var title: String = ""
    var author: String = ""
    var pageCount: Int = 0
    var currentPage: Int = 0
    var estimatedMinutes: Int = 0
    var notes: String = ""
    var dueDate: Date?
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now

    var course: Course?

    @Relationship(deleteRule: .cascade, inverse: \Attachment.reading)
    var attachments: [Attachment] = []

    init(
        id: UUID = UUID(),
        title: String,
        author: String = "",
        pageCount: Int = 0,
        currentPage: Int = 0,
        estimatedMinutes: Int = 0,
        notes: String = "",
        dueDate: Date? = nil,
        createdAt: Date = Date.now,
        updatedAt: Date = Date.now
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.pageCount = pageCount
        self.currentPage = currentPage
        self.estimatedMinutes = estimatedMinutes
        self.notes = notes
        self.dueDate = dueDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
