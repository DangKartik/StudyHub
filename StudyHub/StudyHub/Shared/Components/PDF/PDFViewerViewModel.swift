import Foundation
@preconcurrency import PDFKit

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
    private let pdfProgressRepository: any PDFProgressRepositoryProtocol

    private(set) var document: PDFDocument?
    private(set) var loadError: StudyHubError?

    private(set) var bookmarks: [Bookmark] = []
    private(set) var bookmarkError: StudyHubError?

    /// The page to reopen this PDF on — wherever the user literally left
    /// off, not the furthest page reached (that's tracked separately, for
    /// progress display only; see `PDFProgress.highestPageIndex`). Loaded
    /// once via `loadLastPosition()`, then kept current in-memory as
    /// `saveProgress` is called. `nil` until `loadLastPosition()` is called,
    /// and stays `nil` if nothing was ever saved for this `sourceURL` —
    /// either way the viewer just opens on page 1.
    private(set) var lastPageIndex: Int?

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

    init(
        sourceURL: String,
        pdfService: any PDFServiceProtocol,
        bookmarkRepository: any BookmarkRepositoryProtocol,
        pdfProgressRepository: any PDFProgressRepositoryProtocol
    ) {
        self.sourceURL = sourceURL
        self.pdfService = pdfService
        self.bookmarkRepository = bookmarkRepository
        self.pdfProgressRepository = pdfProgressRepository
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

    // MARK: Reading position

    /// Loads wherever the user literally left off in this PDF, if any — call
    /// once, before the PDF view is first created, so it can open directly
    /// on that page.
    func loadLastPosition() {
        lastPageIndex = (try? pdfProgressRepository.fetch(sourceURL: sourceURL))?.lastPageIndex
    }

    /// Called on every page change while reading and once more when the
    /// viewer closes. Always records `pageIndex` as the literal last-viewed
    /// position (moves both directions — that's what reopening uses), and
    /// separately advances the progress-percentage high-water mark only
    /// when `pageIndex` is actually further than before (handled inside the
    /// repository); scrolling back to re-read something changes where you
    /// reopen, never the percentage.
    func saveProgress(pageIndex: Int, pageCount: Int) {
        lastPageIndex = pageIndex
        try? pdfProgressRepository.saveProgress(sourceURL: sourceURL, pageIndex: pageIndex, pageCount: pageCount)
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

    private var hasPrewarmedSearchIndex = false
    private var searchRequestGeneration = 0
    private(set) var isSearching = false

    /// `PDFDocument.findString` is synchronous and, on its first call for a
    /// given document, does a full-document text extraction/scan to build
    /// PDFKit's internal search index — main-actor-bound, this is what was
    /// freezing the whole UI for a few seconds on a large PDF (worst on the
    /// very first search, since later ones reuse the already-built index).
    /// Routing every call — prewarm included — through this one serial
    /// background queue keeps that work off the main thread, and
    /// guarantees calls never run concurrently with each other: PDFKit
    /// doesn't document `findString` as safe for concurrent access from
    /// multiple threads at once, so a real search typed while the prewarm
    /// is still running simply queues behind it instead of racing it.
    private static let searchQueue = DispatchQueue(label: "com.studyhub.pdf-find", qos: .userInitiated)

    private static func performFindString(
        _ query: String,
        in document: PDFDocument,
        options: NSString.CompareOptions
    ) async -> [PDFSelection] {
        // `PDFDocument` isn't `Sendable`, so capturing it in the `@Sendable`
        // closure below trips strict concurrency checking — but every call
        // here is already funneled through the single serial `searchQueue`
        // (see its doc comment), so there's no actual concurrent access to
        // guard against. `nonisolated(unsafe)` tells the compiler that's a
        // deliberate, already-safe capture rather than working around the
        // check some less direct way.
        nonisolated(unsafe) let document = document
        return await withCheckedContinuation { continuation in
            searchQueue.async {
                continuation.resume(returning: document.findString(query, withOptions: options))
            }
        }
    }

    var currentMatch: PDFSearchMatch? {
        guard let currentMatchIndex, searchMatches.indices.contains(currentMatchIndex) else { return nil }
        return searchMatches[currentMatchIndex]
    }

    /// Pays `findString`'s one-time index-build cost early, off the main
    /// thread. Call this the moment Find opens, before the user has typed
    /// anything — searches for a string guaranteed not to appear in the
    /// document (a UUID), so the scan still runs but there's essentially no
    /// result set to build.
    func prewarmSearchIndex() {
        guard let document, !hasPrewarmedSearchIndex else { return }
        hasPrewarmedSearchIndex = true
        isSearching = true
        Task {
            _ = await Self.performFindString(UUID().uuidString, in: document, options: [])
            isSearching = false
        }
    }

    /// `searchRequestGeneration` guards against a slower, older search
    /// finishing after a newer one and overwriting its results — the
    /// debounce in `PDFFindBar` makes overlap unlikely, not impossible.
    func search(for query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        searchRequestGeneration += 1
        let generation = searchRequestGeneration

        guard !trimmed.isEmpty, let document else {
            searchMatches = []
            currentMatchIndex = nil
            isSearching = false
            searchStateVersion += 1
            return
        }

        isSearching = true
        Task {
            let selections = await Self.performFindString(trimmed, in: document, options: [.caseInsensitive])
            guard generation == searchRequestGeneration else { return }

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
            isSearching = false
            searchStateVersion += 1
        }
    }

    func clearSearch() {
        searchRequestGeneration += 1
        searchMatches = []
        currentMatchIndex = nil
        isSearching = false
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
