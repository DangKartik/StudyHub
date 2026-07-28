import Foundation
import SwiftData

protocol AssignmentRepositoryProtocol {
    func create(_ assignment: Assignment) throws
    func fetchAll() throws -> [Assignment]
    func fetch(id: UUID) throws -> Assignment?
    func delete(_ assignment: Assignment) throws
    func save() throws
    func exists(id: UUID) throws -> Bool
    func count() throws -> Int

    func fetch(forCourse course: Course) throws -> [Assignment]
    func dueToday() throws -> [Assignment]
    func dueThisWeek() throws -> [Assignment]
    func overdue() throws -> [Assignment]
    func completed() throws -> [Assignment]

    func createAttachment(_ attachment: Attachment, for assignment: Assignment) throws
    func deleteAttachment(_ attachment: Attachment) throws
    func fetchAttachments(for assignment: Assignment) throws -> [Attachment]
}

@MainActor
final class AssignmentRepository: AssignmentRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func create(_ assignment: Assignment) throws {
        modelContext.insert(assignment)
        try modelContext.save()
    }

    func fetchAll() throws -> [Assignment] {
        let descriptor = FetchDescriptor<Assignment>(sortBy: [SortDescriptor(\.dueDate)])
        return try modelContext.fetch(descriptor)
    }

    func fetch(id: UUID) throws -> Assignment? {
        var descriptor = FetchDescriptor<Assignment>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    func delete(_ assignment: Assignment) throws {
        modelContext.delete(assignment)
        try modelContext.save()
    }

    func save() throws {
        try modelContext.save()
    }

    func exists(id: UUID) throws -> Bool {
        try fetch(id: id) != nil
    }

    func count() throws -> Int {
        try modelContext.fetchCount(FetchDescriptor<Assignment>())
    }

    func fetch(forCourse course: Course) throws -> [Assignment] {
        course.assignments.sorted { $0.dueDate < $1.dueDate }
    }

    func dueToday() throws -> [Assignment] {
        let startOfDay = Calendar.current.startOfDay(for: .now)
        guard let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }
        let descriptor = FetchDescriptor<Assignment>(
            predicate: #Predicate { $0.dueDate >= startOfDay && $0.dueDate < endOfDay }
        )
        return try modelContext.fetch(descriptor)
    }

    func dueThisWeek() throws -> [Assignment] {
        let startOfDay = Calendar.current.startOfDay(for: .now)
        guard let endOfWeek = Calendar.current.date(byAdding: .day, value: 7, to: startOfDay) else {
            return []
        }
        let descriptor = FetchDescriptor<Assignment>(
            predicate: #Predicate { $0.dueDate >= startOfDay && $0.dueDate < endOfWeek }
        )
        return try modelContext.fetch(descriptor)
    }

    func overdue() throws -> [Assignment] {
        let now = Date.now
        let completedStatus = AssignmentStatus.completed
        let descriptor = FetchDescriptor<Assignment>(
            predicate: #Predicate { $0.dueDate < now && $0.status != completedStatus }
        )
        return try modelContext.fetch(descriptor)
    }

    func completed() throws -> [Assignment] {
        let completedStatus = AssignmentStatus.completed
        let descriptor = FetchDescriptor<Assignment>(
            predicate: #Predicate { $0.status == completedStatus }
        )
        return try modelContext.fetch(descriptor)
    }

    func createAttachment(_ attachment: Attachment, for assignment: Assignment) throws {
        attachment.assignment = assignment
        modelContext.insert(attachment)
        try modelContext.save()
    }

    func deleteAttachment(_ attachment: Attachment) throws {
        modelContext.delete(attachment)
        try modelContext.save()
    }

    func fetchAttachments(for assignment: Assignment) throws -> [Attachment] {
        assignment.attachments.sorted { $0.createdAt < $1.createdAt }
    }
}
