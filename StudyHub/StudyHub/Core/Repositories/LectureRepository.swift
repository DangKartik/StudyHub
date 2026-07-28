import Foundation
import SwiftData

protocol LectureRepositoryProtocol {
    func create(_ lecture: Lecture) throws
    func fetchAll() throws -> [Lecture]
    func fetch(id: UUID) throws -> Lecture?
    func delete(_ lecture: Lecture) throws
    func save() throws
    func exists(id: UUID) throws -> Bool
    func count() throws -> Int

    func fetch(forCourse course: Course) throws -> [Lecture]

    func createAttachment(_ attachment: Attachment, for lecture: Lecture) throws
    func deleteAttachment(_ attachment: Attachment) throws
    func fetchAttachments(for lecture: Lecture) throws -> [Attachment]
}

@MainActor
final class LectureRepository: LectureRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func create(_ lecture: Lecture) throws {
        modelContext.insert(lecture)
        try persistenceSave { try modelContext.save() }
    }

    func fetchAll() throws -> [Lecture] {
        let descriptor = FetchDescriptor<Lecture>(sortBy: [SortDescriptor(\.date)])
        return try persistenceFetch { try modelContext.fetch(descriptor) }
    }

    func fetch(id: UUID) throws -> Lecture? {
        var descriptor = FetchDescriptor<Lecture>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try persistenceFetch { try modelContext.fetch(descriptor).first }
    }

    func delete(_ lecture: Lecture) throws {
        modelContext.delete(lecture)
        try persistenceDelete { try modelContext.save() }
    }

    func save() throws {
        try persistenceSave { try modelContext.save() }
    }

    func exists(id: UUID) throws -> Bool {
        try fetch(id: id) != nil
    }

    func count() throws -> Int {
        try persistenceFetch { try modelContext.fetchCount(FetchDescriptor<Lecture>()) }
    }

    func fetch(forCourse course: Course) throws -> [Lecture] {
        course.lectures.sorted { $0.date < $1.date }
    }

    func createAttachment(_ attachment: Attachment, for lecture: Lecture) throws {
        attachment.lecture = lecture
        modelContext.insert(attachment)
        try persistenceSave { try modelContext.save() }
    }

    func deleteAttachment(_ attachment: Attachment) throws {
        modelContext.delete(attachment)
        try persistenceDelete { try modelContext.save() }
    }

    func fetchAttachments(for lecture: Lecture) throws -> [Attachment] {
        lecture.attachments.sorted { $0.createdAt < $1.createdAt }
    }
}
