import Foundation
import SwiftData

protocol BookmarkRepositoryProtocol {
    func create(_ bookmark: Bookmark) throws
    func fetch(sourceURL: String) throws -> [Bookmark]
    func delete(_ bookmark: Bookmark) throws
}

@MainActor
final class BookmarkRepository: BookmarkRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func create(_ bookmark: Bookmark) throws {
        modelContext.insert(bookmark)
        try persistenceSave { try modelContext.save() }
    }

    func fetch(sourceURL: String) throws -> [Bookmark] {
        let descriptor = FetchDescriptor<Bookmark>(
            predicate: #Predicate { $0.sourceURL == sourceURL },
            sortBy: [SortDescriptor(\.pageIndex)]
        )
        return try persistenceFetch { try modelContext.fetch(descriptor) }
    }

    func delete(_ bookmark: Bookmark) throws {
        modelContext.delete(bookmark)
        try persistenceDelete { try modelContext.save() }
    }
}
