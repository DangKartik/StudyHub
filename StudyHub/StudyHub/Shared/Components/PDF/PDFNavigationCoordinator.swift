import Observation
import PDFKit

/// Bridges SwiftUI-driven actions (bookmark, search) to the live `PDFView`
/// instance, which otherwise stays fully encapsulated inside the private
/// `PDFKitRepresentedView` wrapper — mirrors how `PDFMarkupCoordinator`
/// already bridges markup state the same way. Holds only a weak reference;
/// the `PDFView` itself owns the strong reference via `UIViewRepresentable`.
///
/// `@Observable` (not just a plain class, as this was originally) because
/// `currentPageIndex` needs to actually notify SwiftUI when the visible page
/// changes from scrolling — a plain computed property read once per `body`
/// evaluation went stale the moment the user scrolled without some unrelated
/// state change forcing a re-render, which is what made the bookmark button
/// (whose bookmarked/not state depends on the current page) look broken.
@MainActor
@Observable
final class PDFNavigationCoordinator {
    private(set) weak var pdfView: PDFView?
    private(set) var currentPageIndex: Int?

    @ObservationIgnored
    private var pageChangeObserver: NSObjectProtocol?

    func attach(_ pdfView: PDFView) {
        guard self.pdfView !== pdfView else { return }
        if let pageChangeObserver {
            NotificationCenter.default.removeObserver(pageChangeObserver)
        }
        self.pdfView = pdfView
        // The documented mechanism (PDFView.h) for knowing when the visible
        // page changes, including from plain scrolling — not just explicit
        // goToPage calls.
        pageChangeObserver = NotificationCenter.default.addObserver(
            forName: .PDFViewPageChanged,
            object: pdfView,
            queue: .main
        ) { [weak self] _ in
            self?.refreshCurrentPageIndex()
        }
        refreshCurrentPageIndex()
    }

    private func refreshCurrentPageIndex() {
        guard let pdfView, let page = pdfView.currentPage, let document = pdfView.document else {
            currentPageIndex = nil
            return
        }
        let index = document.index(for: page)
        currentPageIndex = index == NSNotFound ? nil : index
    }

    func goToPage(index: Int) {
        guard let pdfView, let document = pdfView.document, let page = document.page(at: index) else { return }
        pdfView.go(to: page)
    }

    /// Shows every search match at once (a subtle shared highlight) with the
    /// current match emphasized in a distinct color, and scrolls to reveal
    /// it — done via `highlightedSelections` (a plain, non-animated redraw)
    /// plus one `go(to:)` scroll only. Deliberately does *not* call
    /// `setCurrentSelection(_:animate:)`: its "animate" flag triggers
    /// PDFKit's own attention-drawing flash on top of `go(to:)`'s scroll —
    /// two competing animated transitions is exactly what produced the
    /// shrink/fade-then-jump behavior.
    func showSearchMatches(_ selections: [PDFSelection], currentIndex: Int?) {
        guard let pdfView else { return }
        for (index, selection) in selections.enumerated() {
            selection.color = index == currentIndex
                ? UIColor.systemOrange
                : UIColor.systemYellow.withAlphaComponent(0.45)
        }
        pdfView.highlightedSelections = selections.isEmpty ? nil : selections
        if let currentIndex, selections.indices.contains(currentIndex) {
            pdfView.go(to: selections[currentIndex])
        }
    }

    func clearSearchMatches() {
        pdfView?.highlightedSelections = nil
    }

    deinit {
        if let pageChangeObserver {
            NotificationCenter.default.removeObserver(pageChangeObserver)
        }
    }
}
