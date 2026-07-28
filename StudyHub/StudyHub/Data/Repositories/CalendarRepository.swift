import Foundation
import SwiftData

protocol CalendarRepositoryProtocol {
    func create(_ reference: CalendarEventReference) throws
    func fetchAll() throws -> [CalendarEventReference]
    func fetch(id: UUID) throws -> CalendarEventReference?
    func delete(_ reference: CalendarEventReference) throws
    func save() throws
    func exists(id: UUID) throws -> Bool
    func count() throws -> Int

    func fetch(byEventIdentifier eventIdentifier: String) throws -> CalendarEventReference?
    func updateSyncStatus(_ status: SyncStatus, for reference: CalendarEventReference) throws
}

@MainActor
final class CalendarRepository: CalendarRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func create(_ reference: CalendarEventReference) throws {
        modelContext.insert(reference)
        try modelContext.save()
    }

    func fetchAll() throws -> [CalendarEventReference] {
        let descriptor = FetchDescriptor<CalendarEventReference>()
        return try modelContext.fetch(descriptor)
    }

    func fetch(id: UUID) throws -> CalendarEventReference? {
        var descriptor = FetchDescriptor<CalendarEventReference>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    func delete(_ reference: CalendarEventReference) throws {
        modelContext.delete(reference)
        try modelContext.save()
    }

    func save() throws {
        try modelContext.save()
    }

    func exists(id: UUID) throws -> Bool {
        try fetch(id: id) != nil
    }

    func count() throws -> Int {
        try modelContext.fetchCount(FetchDescriptor<CalendarEventReference>())
    }

    func fetch(byEventIdentifier eventIdentifier: String) throws -> CalendarEventReference? {
        var descriptor = FetchDescriptor<CalendarEventReference>(
            predicate: #Predicate { $0.eventIdentifier == eventIdentifier }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    func updateSyncStatus(_ status: SyncStatus, for reference: CalendarEventReference) throws {
        reference.syncStatus = status
        reference.lastSynced = .now
        try modelContext.save()
    }
}
