import Foundation
import SwiftData

protocol ReadingRepositoryProtocol {
    func create(_ reading: Reading) throws
    func fetchAll() throws -> [Reading]
    func fetch(id: UUID) throws -> Reading?
    func delete(_ reading: Reading) throws
    func save() throws
    func exists(id: UUID) throws -> Bool
    func count() throws -> Int

    func fetch(forCourse course: Course) throws -> [Reading]
    func inProgress() throws -> [Reading]
    func completed() throws -> [Reading]

    func createAttachment(_ attachment: Attachment, for reading: Reading) throws
    func deleteAttachment(_ attachment: Attachment) throws
    func fetchAttachments(for reading: Reading) throws -> [Attachment]
}

@MainActor
final class ReadingRepository: ReadingRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func create(_ reading: Reading) throws {
        modelContext.insert(reading)
        try modelContext.save()
    }

    func fetchAll() throws -> [Reading] {
        let descriptor = FetchDescriptor<Reading>(sortBy: [SortDescriptor(\.title)])
        return try modelContext.fetch(descriptor)
    }

    func fetch(id: UUID) throws -> Reading? {
        var descriptor = FetchDescriptor<Reading>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    func delete(_ reading: Reading) throws {
        modelContext.delete(reading)
        try modelContext.save()
    }

    func save() throws {
        try modelContext.save()
    }

    func exists(id: UUID) throws -> Bool {
        try fetch(id: id) != nil
    }

    func count() throws -> Int {
        try modelContext.fetchCount(FetchDescriptor<Reading>())
    }

    func fetch(forCourse course: Course) throws -> [Reading] {
        course.readings.sorted { $0.title < $1.title }
    }

    func inProgress() throws -> [Reading] {
        let descriptor = FetchDescriptor<Reading>(
            predicate: #Predicate { $0.currentPage > 0 && $0.currentPage < $0.pageCount }
        )
        return try modelContext.fetch(descriptor)
    }

    func completed() throws -> [Reading] {
        let descriptor = FetchDescriptor<Reading>(
            predicate: #Predicate { $0.pageCount > 0 && $0.currentPage >= $0.pageCount }
        )
        return try modelContext.fetch(descriptor)
    }

    func createAttachment(_ attachment: Attachment, for reading: Reading) throws {
        attachment.reading = reading
        modelContext.insert(attachment)
        try modelContext.save()
    }

    func deleteAttachment(_ attachment: Attachment) throws {
        modelContext.delete(attachment)
        try modelContext.save()
    }

    func fetchAttachments(for reading: Reading) throws -> [Attachment] {
        reading.attachments.sorted { $0.createdAt < $1.createdAt }
    }
}
