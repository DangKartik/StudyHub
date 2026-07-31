import Foundation
import SwiftData

protocol PDFProgressRepositoryProtocol {
    func fetch(sourceURL: String) throws -> PDFProgress?
    func saveProgress(sourceURL: String, pageIndex: Int, pageCount: Int) throws
}

@MainActor
final class PDFProgressRepository: PDFProgressRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetch(sourceURL: String) throws -> PDFProgress? {
        var descriptor = FetchDescriptor<PDFProgress>(predicate: #Predicate { $0.sourceURL == sourceURL })
        descriptor.fetchLimit = 1
        return try persistenceFetch { try modelContext.fetch(descriptor).first }
    }

    /// Upserts — one `PDFProgress` row per `sourceURL`, updated in place
    /// rather than appended. `lastPageIndex` is a plain overwrite (moves
    /// both directions, so reopening lands wherever the user actually left
    /// off); `highestPageIndex` only ever moves forward (`max` against
    /// whatever's already stored), so the progress percentage can't regress
    /// just because the user paged backward.
    func saveProgress(sourceURL: String, pageIndex: Int, pageCount: Int) throws {
        if let existing = try fetch(sourceURL: sourceURL) {
            existing.lastPageIndex = pageIndex
            existing.highestPageIndex = max(existing.highestPageIndex, pageIndex)
            existing.pageCount = pageCount
            existing.updatedAt = .now
        } else {
            modelContext.insert(PDFProgress(
                sourceURL: sourceURL,
                lastPageIndex: pageIndex,
                highestPageIndex: pageIndex,
                pageCount: pageCount
            ))
        }
        try persistenceSave { try modelContext.save() }
    }
}
