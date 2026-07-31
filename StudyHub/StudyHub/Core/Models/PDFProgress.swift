import Foundation
import SwiftData

/// A PDF's reading state, identified by the same `sourceURL` string used
/// everywhere else a PDF is referenced (`Attachment.url` / `Resource.url` /
/// plain URL strings) — same identity approach as `Bookmark`. One row per
/// PDF (upserted, not appended), updated automatically as the user reads:
/// no user input, no relationship to any specific owner (Note/Reading/
/// Resource), since a PDF's identity has always been its URL, not an
/// owning row.
///
/// Two separate positions, deliberately not one:
/// - `lastPageIndex` — wherever the user literally left off, moves both
///   directions, used only to reopen the PDF on the same page it was closed on.
/// - `highestPageIndex` — the furthest page ever reached, only ever moves
///   forward, used only for the progress percentage. Paging back to re-read
///   something earlier changes where you reopen, but never the percentage.
@Model
final class PDFProgress {
    var sourceURL: String = ""
    var lastPageIndex: Int = 0
    var highestPageIndex: Int = 0
    var pageCount: Int = 0
    var updatedAt: Date = Date.now

    init(
        sourceURL: String,
        lastPageIndex: Int,
        highestPageIndex: Int,
        pageCount: Int,
        updatedAt: Date = Date.now
    ) {
        self.sourceURL = sourceURL
        self.lastPageIndex = lastPageIndex
        self.highestPageIndex = highestPageIndex
        self.pageCount = pageCount
        self.updatedAt = updatedAt
    }
}
