import Foundation
import SwiftData

protocol NoteRepositoryProtocol {
    func create(_ note: Note) throws
    func fetchAll() throws -> [Note]
    func fetch(id: UUID) throws -> Note?
    func delete(_ note: Note) throws
    func save() throws
    func exists(id: UUID) throws -> Bool
    func count() throws -> Int

    func fetch(forCourse course: Course) throws -> [Note]
    func fetch(forLecture lecture: Lecture) throws -> [Note]

    func createAttachment(_ attachment: Attachment, for note: Note) throws
    func deleteAttachment(_ attachment: Attachment) throws
    func fetchAttachments(for note: Note) throws -> [Attachment]
}

@MainActor
final class NoteRepository: NoteRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func create(_ note: Note) throws {
        modelContext.insert(note)
        try persistenceSave { try modelContext.save() }
    }

    func fetchAll() throws -> [Note] {
        let descriptor = FetchDescriptor<Note>(sortBy: [SortDescriptor(\.createdAt)])
        return try persistenceFetch { try modelContext.fetch(descriptor) }
    }

    func fetch(id: UUID) throws -> Note? {
        var descriptor = FetchDescriptor<Note>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try persistenceFetch { try modelContext.fetch(descriptor).first }
    }

    func delete(_ note: Note) throws {
        modelContext.delete(note)
        try persistenceDelete { try modelContext.save() }
    }

    func save() throws {
        try persistenceSave { try modelContext.save() }
    }

    func exists(id: UUID) throws -> Bool {
        try fetch(id: id) != nil
    }

    func count() throws -> Int {
        try persistenceFetch { try modelContext.fetchCount(FetchDescriptor<Note>()) }
    }

    func fetch(forCourse course: Course) throws -> [Note] {
        course.noteEntries.sorted { $0.createdAt < $1.createdAt }
    }

    func fetch(forLecture lecture: Lecture) throws -> [Note] {
        lecture.noteEntries.sorted { $0.createdAt < $1.createdAt }
    }

    func createAttachment(_ attachment: Attachment, for note: Note) throws {
        attachment.note = note
        modelContext.insert(attachment)
        try persistenceSave { try modelContext.save() }
    }

    func deleteAttachment(_ attachment: Attachment) throws {
        modelContext.delete(attachment)
        try persistenceDelete { try modelContext.save() }
    }

    func fetchAttachments(for note: Note) throws -> [Attachment] {
        note.attachments.sorted { $0.createdAt < $1.createdAt }
    }
}
