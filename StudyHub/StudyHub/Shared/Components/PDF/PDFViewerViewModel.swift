import Foundation
import PDFKit

/// One PDF search result, precomputed for display — `PDFSelection` itself
/// exposes `.string`/`.pages`, but callers need the 0-based page index (to
/// match `Bookmark.pageIndex`/`PDFNavigationCoordinator`) and a 1-based
/// page number (for display) alongside the matched text.
struct PDFSearchMatch: Identifiable {
    let id = UUID()
    let selection: PDFSelection
    let text: String
    let pageIndex: Int
    let pageNumber: Int
}

/// One entry in a PDF's table of contents, recursively parsed from
/// `PDFDocument.outlineRoot`'s `PDFOutline` tree. `level` is 0 for a
/// top-level chapter, 1 for its sections, etc. — the tree structure itself
/// (`children`) is preserved too, so a consumer can flatten-with-indent (as
/// `PDFOutlineListView` does) or build real collapsible disclosure groups
/// without re-parsing.
struct PDFOutlineNode: Identifiable {
    let id = UUID()
    let title: String
    let level: Int
    let destination: PDFDestination?
    let children: [PDFOutlineNode]
}

@MainActor
@Observable
final class PDFViewerViewModel {
    private let sourceURL: String
    private let pdfService: any PDFServiceProtocol
    private let bookmarkRepository: any BookmarkRepositoryProtocol

    private(set) var document: PDFDocument?
    private(set) var loadError: StudyHubError?

    private(set) var bookmarks: [Bookmark] = []
    private(set) var bookmarkError: StudyHubError?

    private(set) var outline: [PDFOutlineNode] = []

    private(set) var searchMatches: [PDFSearchMatch] = []
    private(set) var currentMatchIndex: Int?
    /// Bumped on every search-state mutation (`search`, `clearSearch`,
    /// `goToNextMatch`, `goToPreviousMatch`) — the thing the view actually
    /// observes to refresh PDF highlights. `currentMatchIndex` alone isn't
    /// enough: two different queries that each have at least one match both
    /// set it to `0`, so watching it directly misses the change entirely and
    /// leaves the previous query's highlights on screen.
    private(set) var searchStateVersion = 0

    init(sourceURL: String, pdfService: any PDFServiceProtocol, bookmarkRepository: any BookmarkRepositoryProtocol) {
        self.sourceURL = sourceURL
        self.pdfService = pdfService
        self.bookmarkRepository = bookmarkRepository
    }

    func loadDocument() {
        do {
            document = try pdfService.loadDocument(from: sourceURL)
            loadError = nil
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PDFError.documentLoadFailed
        }
    }

    // MARK: Bookmarks

    func loadBookmarks() {
        do {
            bookmarks = try bookmarkRepository.fetch(sourceURL: sourceURL)
            bookmarkError = nil
        } catch let error as StudyHubError {
            bookmarkError = error
        } catch {
            bookmarkError = PersistenceError.fetchFailed(underlying: error)
        }
    }

    func isBookmarked(pageIndex: Int) -> Bool {
        bookmarks.contains { $0.pageIndex == pageIndex }
    }

    /// Adds a bookmark for `pageIndex` if none exists yet, otherwise removes
    /// the existing one — a single toolbar action toggles both directions.
    func toggleBookmark(pageIndex: Int) {
        if let existing = bookmarks.first(where: { $0.pageIndex == pageIndex }) {
            deleteBookmark(existing)
        } else {
            let pageLabel = document?.page(at: pageIndex)?.label
            let bookmark = Bookmark(sourceURL: sourceURL, pageIndex: pageIndex, pageLabel: pageLabel)
            do {
                try bookmarkRepository.create(bookmark)
                bookmarks.append(bookmark)
                bookmarkError = nil
            } catch let error as StudyHubError {
                bookmarkError = error
            } catch {
                bookmarkError = PersistenceError.saveFailed(underlying: error)
            }
        }
    }

    func deleteBookmark(_ bookmark: Bookmark) {
        do {
            try bookmarkRepository.delete(bookmark)
            bookmarks.removeAll { $0.id == bookmark.id }
            bookmarkError = nil
        } catch let error as StudyHubError {
            bookmarkError = error
        } catch {
            bookmarkError = PersistenceError.deleteFailed(underlying: error)
        }
    }

    // MARK: Outline

    var hasOutline: Bool { !outline.isEmpty }

    /// Recursively parses `document.outlineRoot`'s `PDFOutline` tree once
    /// into a plain `[PDFOutlineNode]` — call after `loadDocument()`. A nil
    /// `outlineRoot` (most PDFs — outlines are optional) or a document with
    /// no children just leaves `outline` empty, which the view treats as
    /// "no contents available."
    func loadOutline() {
        guard let root = document?.outlineRoot else {
            outline = []
            return
        }
        outline = Self.children(of: root, level: 0)
    }

    /// Depth-capped defensively — `PDFOutline.h` documents the tree as
    /// acyclic by contract, but that's the PDF author's responsibility, not
    /// something PDFKit validates for us, and a malformed file shouldn't be
    /// able to blow the stack.
    private static func children(of outline: PDFOutline, level: Int) -> [PDFOutlineNode] {
        guard level < 20 else { return [] }
        return (0..<outline.numberOfChildren).compactMap { index -> PDFOutlineNode? in
            guard let child = outline.child(at: index) else { return nil }
            let title = child.label?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !title.isEmpty else { return nil }
            return PDFOutlineNode(
                title: title,
                level: level,
                destination: child.destination,
                children: children(of: child, level: level + 1)
            )
        }
    }

    // MARK: Search

    var currentMatch: PDFSearchMatch? {
        guard let currentMatchIndex, searchMatches.indices.contains(currentMatchIndex) else { return nil }
        return searchMatches[currentMatchIndex]
    }

    /// Synchronous search via `PDFDocument.findString(_:withOptions:)` —
    /// fine for a single in-memory document of the size this app opens;
    /// there's no need for PDFKit's async `beginFindString` + notification
    /// pipeline here.
    func search(for query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let document else {
            searchMatches = []
            currentMatchIndex = nil
            searchStateVersion += 1
            return
        }

        let selections = document.findString(trimmed, withOptions: [.caseInsensitive])
        searchMatches = selections.compactMap { selection in
            guard let page = selection.pages.first else { return nil }
            let pageIndex = document.index(for: page)
            guard pageIndex != NSNotFound else { return nil }
            return PDFSearchMatch(
                selection: selection,
                text: selection.string ?? "",
                pageIndex: pageIndex,
                pageNumber: pageIndex + 1
            )
        }
        currentMatchIndex = searchMatches.isEmpty ? nil : 0
        searchStateVersion += 1
    }

    func clearSearch() {
        searchMatches = []
        currentMatchIndex = nil
        searchStateVersion += 1
    }

    func goToNextMatch() {
        guard !searchMatches.isEmpty else { return }
        let next = (currentMatchIndex ?? -1) + 1
        currentMatchIndex = next < searchMatches.count ? next : 0
        searchStateVersion += 1
    }

    func goToPreviousMatch() {
        guard !searchMatches.isEmpty else { return }
        let previous = (currentMatchIndex ?? 0) - 1
        currentMatchIndex = previous >= 0 ? previous : searchMatches.count - 1
        searchStateVersion += 1
    }
}
