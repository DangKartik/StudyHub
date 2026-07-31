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
            // `queue: .main` guarantees this runs on the main thread, but the
            // closure itself isn't statically `@MainActor` — `assumeIsolated`
            // is the correct, non-`await` bridge for a callback that's truly
            // guaranteed to already be on the main actor's executor.
            MainActor.assumeIsolated {
                self?.refreshCurrentPageIndex()
            }
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

    /// Navigates to an outline entry's destination (page + point + zoom, per
    /// `PDFDestination`), used by the Contents/Outline sheet.
    func goToDestination(_ destination: PDFDestination) {
        pdfView?.go(to: destination)
    }

    /// Highlights every search match at once (a subtle shared highlight)
    /// with the current match emphasized in a distinct color — a plain,
    /// non-scrolling redraw via `highlightedSelections`. Deliberately does
    /// *not* scroll or call `setCurrentSelection(_:animate:)`: this runs on
    /// every keystroke while typing a query, and scrolling the page out
    /// from under the user (and, empirically, dismissing the keyboard along
    /// with it) on every keystroke is exactly the behavior that's wrong.
    /// Scrolling only happens via `goToSelection`, from explicit Next/
    /// Previous taps.
    func highlightSearchMatches(_ selections: [PDFSelection], currentIndex: Int?) {
        guard let pdfView else { return }
        for (index, selection) in selections.enumerated() {
            selection.color = index == currentIndex
                ? UIColor.systemOrange
                : UIColor.systemYellow.withAlphaComponent(0.45)
        }
        pdfView.highlightedSelections = selections.isEmpty ? nil : selections
    }

    /// Scrolls to reveal one specific search match, leaving a top margin so
    /// it doesn't land flush under `PDFFindBar`'s overlay — called only
    /// from explicit Next/Previous actions, never from typing.
    ///
    /// Deliberately uses `goToRect(_:on:)`, not the more obvious
    /// `goToSelection(_:)` — two reasons: (1) `goToSelection` has no way to
    /// add margin, it just reveals the selection's first character; (2)
    /// `PDFView.h` documents *both* methods as "if already visible, does
    /// nothing" — this is almost certainly why plain `goToSelection` was
    /// intermittently a no-op requiring repeated presses (PDFKit considered
    /// the destination "already visible" even when it wasn't positioned
    /// anywhere near where you'd want it). The padded rect this constructs
    /// (selection height plus ~28% of the viewport) is large enough that
    /// it's rarely already fully on-screen, which sidesteps that no-op case
    /// too, not just adds the margin.
    func goToSelection(_ selection: PDFSelection) {
        guard let pdfView, let page = selection.pages.first else { return }
        let selectionBounds = selection.bounds(for: page)
        let scale = pdfView.scaleFactor > 0 ? pdfView.scaleFactor : 1
        // Screen-space margin converted to page-space via the live zoom
        // scale, since `goToRect(_:on:)` takes page coordinates, not points
        // on screen.
        let topMarginInPageSpace = (pdfView.bounds.height * 0.28) / scale
        let paddedRect = CGRect(
            x: selectionBounds.minX,
            y: selectionBounds.minY,
            width: selectionBounds.width,
            height: selectionBounds.height + topMarginInPageSpace
        )
        pdfView.go(to: paddedRect, on: page)
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
