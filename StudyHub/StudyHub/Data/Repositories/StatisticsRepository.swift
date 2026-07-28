import Foundation
import SwiftData

protocol StatisticsRepositoryProtocol {
    func create(_ snapshot: StatisticsSnapshot) throws
    func fetchAll() throws -> [StatisticsSnapshot]
    func fetch(id: UUID) throws -> StatisticsSnapshot?
    func delete(_ snapshot: StatisticsSnapshot) throws
    func save() throws
    func exists(id: UUID) throws -> Bool
    func count() throws -> Int

    func fetch(forSemester semester: Semester) throws -> [StatisticsSnapshot]
    func fetch(from startDate: Date, to endDate: Date) throws -> [StatisticsSnapshot]
}

@MainActor
final class StatisticsRepository: StatisticsRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func create(_ snapshot: StatisticsSnapshot) throws {
        modelContext.insert(snapshot)
        try modelContext.save()
    }

    func fetchAll() throws -> [StatisticsSnapshot] {
        let descriptor = FetchDescriptor<StatisticsSnapshot>(sortBy: [SortDescriptor(\.date)])
        return try modelContext.fetch(descriptor)
    }

    func fetch(id: UUID) throws -> StatisticsSnapshot? {
        var descriptor = FetchDescriptor<StatisticsSnapshot>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    func delete(_ snapshot: StatisticsSnapshot) throws {
        modelContext.delete(snapshot)
        try modelContext.save()
    }

    func save() throws {
        try modelContext.save()
    }

    func exists(id: UUID) throws -> Bool {
        try fetch(id: id) != nil
    }

    func count() throws -> Int {
        try modelContext.fetchCount(FetchDescriptor<StatisticsSnapshot>())
    }

    func fetch(forSemester semester: Semester) throws -> [StatisticsSnapshot] {
        semester.statisticsSnapshots.sorted { $0.date < $1.date }
    }

    func fetch(from startDate: Date, to endDate: Date) throws -> [StatisticsSnapshot] {
        let descriptor = FetchDescriptor<StatisticsSnapshot>(
            predicate: #Predicate { $0.date >= startDate && $0.date < endDate },
            sortBy: [SortDescriptor(\.date)]
        )
        return try modelContext.fetch(descriptor)
    }
}
