import Foundation
import SwiftData

protocol StudySessionRepositoryProtocol {
    func create(_ session: StudySession) throws
    func fetchAll() throws -> [StudySession]
    func fetch(id: UUID) throws -> StudySession?
    func delete(_ session: StudySession) throws
    func save() throws
    func exists(id: UUID) throws -> Bool
    func count() throws -> Int

    func fetch(forSemester semester: Semester) throws -> [StudySession]
    func fetch(forCourse course: Course) throws -> [StudySession]
}

@MainActor
final class StudySessionRepository: StudySessionRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func create(_ session: StudySession) throws {
        modelContext.insert(session)
        try persistenceSave { try modelContext.save() }
    }

    func fetchAll() throws -> [StudySession] {
        let descriptor = FetchDescriptor<StudySession>(sortBy: [SortDescriptor(\.startTime, order: .reverse)])
        return try persistenceFetch { try modelContext.fetch(descriptor) }
    }

    func fetch(id: UUID) throws -> StudySession? {
        var descriptor = FetchDescriptor<StudySession>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try persistenceFetch { try modelContext.fetch(descriptor).first }
    }

    func delete(_ session: StudySession) throws {
        modelContext.delete(session)
        try persistenceDelete { try modelContext.save() }
    }

    func save() throws {
        try persistenceSave { try modelContext.save() }
    }

    func exists(id: UUID) throws -> Bool {
        try fetch(id: id) != nil
    }

    func count() throws -> Int {
        try persistenceFetch { try modelContext.fetchCount(FetchDescriptor<StudySession>()) }
    }

    func fetch(forSemester semester: Semester) throws -> [StudySession] {
        semester.studySessions.sorted { $0.startTime > $1.startTime }
    }

    func fetch(forCourse course: Course) throws -> [StudySession] {
        course.studySessions.sorted { $0.startTime > $1.startTime }
    }
}
