import Foundation
import SwiftData

protocol QuoteRepositoryProtocol {
    func create(_ quote: Quote) throws
    func fetchAll() throws -> [Quote]
    func fetch(id: UUID) throws -> Quote?
    func delete(_ quote: Quote) throws
    func save() throws
    func exists(id: UUID) throws -> Bool
    func count() throws -> Int

    func search(query: String) throws -> [Quote]
    func nextQuote() throws -> Quote?
}

@MainActor
final class QuoteRepository: QuoteRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func create(_ quote: Quote) throws {
        modelContext.insert(quote)
        try modelContext.save()
    }

    func fetchAll() throws -> [Quote] {
        let descriptor = FetchDescriptor<Quote>(sortBy: [SortDescriptor(\.createdAt)])
        return try modelContext.fetch(descriptor)
    }

    func fetch(id: UUID) throws -> Quote? {
        var descriptor = FetchDescriptor<Quote>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    func delete(_ quote: Quote) throws {
        modelContext.delete(quote)
        try modelContext.save()
    }

    func save() throws {
        try modelContext.save()
    }

    func exists(id: UUID) throws -> Bool {
        try fetch(id: id) != nil
    }

    func count() throws -> Int {
        try modelContext.fetchCount(FetchDescriptor<Quote>())
    }

    func search(query: String) throws -> [Quote] {
        let descriptor = FetchDescriptor<Quote>(predicate: #Predicate { $0.text.localizedStandardContains(query) })
        return try modelContext.fetch(descriptor)
    }

    func nextQuote() throws -> Quote? {
        let unshownDescriptor = FetchDescriptor<Quote>(predicate: #Predicate { $0.hasBeenShown == false })
        var candidates = try modelContext.fetch(unshownDescriptor)

        if candidates.isEmpty {
            let all = try modelContext.fetch(FetchDescriptor<Quote>())
            guard !all.isEmpty else { return nil }
            for quote in all {
                quote.hasBeenShown = false
            }
            candidates = all
        }

        guard let selected = candidates.randomElement() else { return nil }
        selected.hasBeenShown = true
        selected.lastShown = .now
        try modelContext.save()
        return selected
    }
}
