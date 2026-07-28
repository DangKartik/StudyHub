import Foundation
import SwiftData

protocol ActiveRecallRepositoryProtocol {
    func create(_ question: ActiveRecallQuestion) throws
    func fetchAll() throws -> [ActiveRecallQuestion]
    func fetch(id: UUID) throws -> ActiveRecallQuestion?
    func delete(_ question: ActiveRecallQuestion) throws
    func save() throws
    func exists(id: UUID) throws -> Bool
    func count() throws -> Int

    func fetch(forLecture lecture: Lecture) throws -> [ActiveRecallQuestion]
}

@MainActor
final class ActiveRecallRepository: ActiveRecallRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func create(_ question: ActiveRecallQuestion) throws {
        modelContext.insert(question)
        try modelContext.save()
    }

    func fetchAll() throws -> [ActiveRecallQuestion] {
        let descriptor = FetchDescriptor<ActiveRecallQuestion>()
        return try modelContext.fetch(descriptor)
    }

    func fetch(id: UUID) throws -> ActiveRecallQuestion? {
        var descriptor = FetchDescriptor<ActiveRecallQuestion>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    func delete(_ question: ActiveRecallQuestion) throws {
        modelContext.delete(question)
        try modelContext.save()
    }

    func save() throws {
        try modelContext.save()
    }

    func exists(id: UUID) throws -> Bool {
        try fetch(id: id) != nil
    }

    func count() throws -> Int {
        try modelContext.fetchCount(FetchDescriptor<ActiveRecallQuestion>())
    }

    func fetch(forLecture lecture: Lecture) throws -> [ActiveRecallQuestion] {
        lecture.activeRecallQuestions
    }
}
