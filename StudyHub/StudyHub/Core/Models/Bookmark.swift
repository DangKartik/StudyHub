import Foundation
import SwiftData

/// A saved page position within a PDF, identified by the same `sourceURL`
/// string already used everywhere else a PDF is referenced (`Attachment.url`
/// / `Resource.url`) — no relationship to an `Attachment`/`Resource` model,
/// since a PDF's identity in this app has always been its URL string, not an
/// owning row.
@Model
final class Bookmark {
    var id: UUID = UUID()
    var sourceURL: String = ""
    var pageIndex: Int = 0
    /// `PDFPage.label` at creation time, e.g. "iv" or "12" — nil when the
    /// document has no custom page labeling. Display-only; navigation always
    /// uses `pageIndex`.
    var pageLabel: String?
    var createdAt: Date = Date.now

    init(
        id: UUID = UUID(),
        sourceURL: String,
        pageIndex: Int,
        pageLabel: String? = nil,
        createdAt: Date = Date.now
    ) {
        self.id = id
        self.sourceURL = sourceURL
        self.pageIndex = pageIndex
        self.pageLabel = pageLabel
        self.createdAt = createdAt
    }
}
