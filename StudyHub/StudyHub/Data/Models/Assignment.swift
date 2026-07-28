import Foundation
import SwiftData

@Model
final class Assignment {
    var id: UUID = UUID()
    var title: String = ""
    var assignmentDescription: String = ""
    var priority: Priority = Priority.medium
    var status: AssignmentStatus = AssignmentStatus.notStarted
    var progress: Double = 0
    var dueDate: Date = Date.now
    var submissionDate: Date?
    var estimatedHours: Double = 0
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now

    var course: Course?

    @Relationship(deleteRule: .cascade, inverse: \Attachment.assignment)
    var attachments: [Attachment] = []

    @Relationship(deleteRule: .cascade)
    var calendarEventReference: CalendarEventReference?

    init(
        id: UUID = UUID(),
        title: String,
        assignmentDescription: String = "",
        priority: Priority = .medium,
        status: AssignmentStatus = .notStarted,
        progress: Double = 0,
        dueDate: Date,
        submissionDate: Date? = nil,
        estimatedHours: Double = 0,
        createdAt: Date = Date.now,
        updatedAt: Date = Date.now
    ) {
        self.id = id
        self.title = title
        self.assignmentDescription = assignmentDescription
        self.priority = priority
        self.status = status
        self.progress = progress
        self.dueDate = dueDate
        self.submissionDate = submissionDate
        self.estimatedHours = estimatedHours
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
