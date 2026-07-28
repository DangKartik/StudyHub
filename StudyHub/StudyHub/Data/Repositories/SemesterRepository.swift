import Foundation
import SwiftData

protocol SemesterRepositoryProtocol {
    func create(_ semester: Semester) throws
    func fetchAll() throws -> [Semester]
    func fetch(id: UUID) throws -> Semester?
    func delete(_ semester: Semester) throws
    func save() throws
    func exists(id: UUID) throws -> Bool
    func count() throws -> Int

    func archive(_ semester: Semester) throws
    func fetchActive() throws -> Semester?
    func setActive(_ semester: Semester) throws
}

@MainActor
final class SemesterRepository: SemesterRepositoryProtocol {
    private static let activeSemesterIDKey = "activeSemesterID"

    private let modelContext: ModelContext
    private let userDefaults: UserDefaults

    init(modelContext: ModelContext, userDefaults: UserDefaults = .standard) {
        self.modelContext = modelContext
        self.userDefaults = userDefaults
    }

    func create(_ semester: Semester) throws {
        modelContext.insert(semester)
        try modelContext.save()
    }

    func fetchAll() throws -> [Semester] {
        let descriptor = FetchDescriptor<Semester>(sortBy: [SortDescriptor(\.startDate, order: .reverse)])
        return try modelContext.fetch(descriptor)
    }

    func fetch(id: UUID) throws -> Semester? {
        var descriptor = FetchDescriptor<Semester>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    func delete(_ semester: Semester) throws {
        modelContext.delete(semester)
        try modelContext.save()
    }

    func save() throws {
        try modelContext.save()
    }

    func exists(id: UUID) throws -> Bool {
        try fetch(id: id) != nil
    }

    func count() throws -> Int {
        try modelContext.fetchCount(FetchDescriptor<Semester>())
    }

    func archive(_ semester: Semester) throws {
        semester.isArchived = true
        try modelContext.save()
    }

    func fetchActive() throws -> Semester? {
        guard
            let idString = userDefaults.string(forKey: Self.activeSemesterIDKey),
            let id = UUID(uuidString: idString)
        else {
            return nil
        }
        return try fetch(id: id)
    }

    func setActive(_ semester: Semester) throws {
        userDefaults.set(semester.id.uuidString, forKey: Self.activeSemesterIDKey)
    }
}
