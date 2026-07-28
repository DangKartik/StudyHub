import Foundation
import SwiftData

protocol ResourceRepositoryProtocol {
    func create(_ resource: Resource) throws
    func fetchAll() throws -> [Resource]
    func fetch(id: UUID) throws -> Resource?
    func delete(_ resource: Resource) throws
    func save() throws
    func exists(id: UUID) throws -> Bool
    func count() throws -> Int

    func fetch(forCourse course: Course) throws -> [Resource]
}

@MainActor
final class ResourceRepository: ResourceRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func create(_ resource: Resource) throws {
        modelContext.insert(resource)
        try modelContext.save()
    }

    func fetchAll() throws -> [Resource] {
        let descriptor = FetchDescriptor<Resource>(sortBy: [SortDescriptor(\.title)])
        return try modelContext.fetch(descriptor)
    }

    func fetch(id: UUID) throws -> Resource? {
        var descriptor = FetchDescriptor<Resource>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    func delete(_ resource: Resource) throws {
        modelContext.delete(resource)
        try modelContext.save()
    }

    func save() throws {
        try modelContext.save()
    }

    func exists(id: UUID) throws -> Bool {
        try fetch(id: id) != nil
    }

    func count() throws -> Int {
        try modelContext.fetchCount(FetchDescriptor<Resource>())
    }

    func fetch(forCourse course: Course) throws -> [Resource] {
        course.resources.sorted { $0.title < $1.title }
    }
}
