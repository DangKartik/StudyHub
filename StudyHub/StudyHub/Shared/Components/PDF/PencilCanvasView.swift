import PDFKit
import PencilKit
import SwiftUI

/// One PDF page's worth of PencilKit markup — `pageIndex` is 0-based,
/// matching `PDFDocument.index(for:)`. `drawingData` is a raw
/// `PKDrawing.dataRepresentation()` blob in that page's own native point
/// space. An array of these, JSON-encoded, is what's stored in
/// `Attachment.markupData` / `Resource.markupData` (Phase 3N.6.4) — no
/// separate model/table needed for per-page storage.
private struct PDFPageMarkup: Codable {
    let pageIndex: Int
    let drawingData: Data
}

/// Supplies a `PKCanvasView` per PDF page via PDFKit's own
/// `PDFPageOverlayViewProvider` (iOS 16+) — the framework itself keeps each
/// returned view positioned and scaled to exactly cover its page across
/// zoom, scroll, reopening, and device rotation, so no manual coordinate
/// transform is needed here. `PDFView.isInMarkupMode` (toggled by
/// `PDFViewerView` alongside Markup on/off) switches touch routing between
/// these overlay canvases (drawing) and the PDF itself (scroll/zoom/select)
/// instead of the two competing for touches.
///
/// One canvas is created and cached per `PDFPage` the first time PDFKit
/// asks for it, and kept for the lifetime of the PDF view — this is what
/// lets a page's in-progress markup survive scrolling away and back without
/// being discarded, and is what `exportMarkupData()` reads from at save
/// time (every cached page, not just the currently visible one).
@MainActor
final class PDFMarkupCoordinator: NSObject, PDFPageOverlayViewProvider, PKCanvasViewDelegate {
    private weak var toolManager: PencilToolManager?
    private var onStrokeBegan: (() -> Void)?
    private var canvasesByPage: [ObjectIdentifier: PKCanvasView] = [:]
    private var pagesByIdentifier: [ObjectIdentifier: PDFPage] = [:]
    private var storedMarkupByPageIndex: [Int: Data] = [:]
    private weak var document: PDFDocument?

    func configure(toolManager: PencilToolManager, onStrokeBegan: @escaping () -> Void) {
        self.toolManager = toolManager
        self.onStrokeBegan = onStrokeBegan
    }

    /// Decodes previously-saved markup, ready to apply to each page's
    /// canvas lazily as PDFKit actually asks for it (`overlayViewFor:`) —
    /// call once when a PDF (with possibly-existing markup) is opened.
    func loadStoredMarkup(_ data: Data?, document: PDFDocument?) {
        self.document = document
        guard let data, let entries = try? JSONDecoder().decode([PDFPageMarkup].self, from: data) else {
            storedMarkupByPageIndex = [:]
            return
        }
        storedMarkupByPageIndex = Dictionary(uniqueKeysWithValues: entries.map { ($0.pageIndex, $0.drawingData) })
    }

    /// Gathers every cached page canvas's current drawing into the
    /// serialized form stored on the owning Attachment/Resource. Returns
    /// `nil` when there's nothing worth saving (no page has any strokes).
    func exportMarkupData() -> Data? {
        guard let document else { return nil }
        var entries: [PDFPageMarkup] = []
        for (identifier, canvas) in canvasesByPage {
            guard !canvas.drawing.strokes.isEmpty, let page = pagesByIdentifier[identifier] else { continue }
            let pageIndex = document.index(for: page)
            guard pageIndex != NSNotFound else { continue }
            entries.append(PDFPageMarkup(pageIndex: pageIndex, drawingData: canvas.drawing.dataRepresentation()))
        }
        guard !entries.isEmpty else { return nil }
        return try? JSONEncoder().encode(entries)
    }

    /// Pushes the tool manager's current tool onto every cached canvas —
    /// called whenever `PDFViewerView` re-renders with a changed tool, since
    /// more than one page's canvas can exist at once.
    func refreshTool() {
        guard let tool = toolManager?.currentTool else { return }
        for canvas in canvasesByPage.values {
            canvas.tool = tool
        }
    }

    /// Cancels any in-progress PencilKit lasso selection on every cached
    /// page's canvas — called on every Markup mode on/off transition so a
    /// selection never survives past leaving Markup mode. PKCanvasView has
    /// no public "deselect" API. `PKTool` conformers (`PKLassoTool` etc.)
    /// are `Equatable` value types — `PKLassoTool` has no stored properties,
    /// so every instance is `==` every other — meaning reassigning `tool` to
    /// its own current value risks being a silent no-op if PencilKit's
    /// internal setter short-circuits on equality. Switching to a genuinely
    /// different tool value and back is what reliably tears down the
    /// selection UI regardless of that. This only touches the canvas's live
    /// tool state, not `PencilToolManager`'s remembered selection/settings,
    /// and never touches `drawing`, so strokes and persistence are unaffected.
    func clearActiveSelections() {
        for canvas in canvasesByPage.values {
            let activeTool = canvas.tool
            canvas.tool = PKInkingTool(.pen)
            canvas.tool = activeTool
        }
    }

    // MARK: PDFPageOverlayViewProvider

    func pdfView(_ view: PDFView, overlayViewFor page: PDFPage) -> UIView? {
        let identifier = ObjectIdentifier(page)
        if let existing = canvasesByPage[identifier] {
            return existing
        }

        let canvas = PKCanvasView()
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.isUserInteractionEnabled = true
        canvas.clipsToBounds = false
        // PDFPageOverlayViewProvider.h documents that PDFKit sizes/positions
        // this view via its own explicit Auto Layout constraints once added
        // to the hierarchy ("constraints have been set up"). Per Apple's own
        // Auto Layout contract, any view managed by external constraints
        // must disable this, otherwise UIKit keeps a second, implicit
        // constraint set (derived from frame/autoresizingMask) alive
        // alongside PDFKit's real one. That ambiguity was invisible during
        // ordinary zoom/scroll, but PencilKit's lasso-move gesture runs its
        // own concurrent interactive render loop on this same view — during
        // the drag, a stale implicit constraint could transiently win over
        // PDFKit's real one, undersizing what's rendered until the next full
        // layout pass (i.e. exactly "shrinks while moving, correct on drop").
        canvas.translatesAutoresizingMaskIntoConstraints = false
        // Explicit rather than the default 1.0 — this canvas is created here,
        // before it's added to any window, so it can't yet inherit the real
        // screen scale otherwise.
        canvas.contentScaleFactor = UIScreen.main.scale
        // Same dark-mode-ink fix as the rest of the markup pipeline.
        canvas.overrideUserInterfaceStyle = .light
        canvas.delegate = self
        canvas.tool = toolManager?.currentTool ?? PKInkingTool(.pen)
        // Sized to the page's own native point space — PDFKit itself scales
        // and positions this view to match the page's current on-screen
        // rect, so the canvas's internal coordinate space (and therefore
        // every stroke drawn on it) never has to know about zoom or scroll.
        canvas.frame = CGRect(origin: .zero, size: page.bounds(for: .mediaBox).size)

        let activeDocument = document ?? view.document
        if let activeDocument {
            let pageIndex = activeDocument.index(for: page)
            if pageIndex != NSNotFound,
               let storedData = storedMarkupByPageIndex[pageIndex],
               let drawing = try? PKDrawing(data: storedData) {
                canvas.drawing = drawing
            }
        }

        canvasesByPage[identifier] = canvas
        pagesByIdentifier[identifier] = page
        document = activeDocument

        return canvas
    }

    // Called once the overlay view is actually in PDFView's hierarchy with
    // constraints resolved — the documented place (per PDFPageOverlayViewProvider.h)
    // to set up gesture coordination with `pdfView`'s own recognizers, since
    // doing this in `overlayViewFor:` would run before the view has a window.
    func pdfView(_ pdfView: PDFView, willDisplayOverlayView overlayView: UIView, for page: PDFPage) {
        guard let canvasView = overlayView as? PKCanvasView else { return }
        canvasView.becomeFirstResponder()
    }

    // MARK: PKCanvasViewDelegate

    func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
        // Re-targets undo/redo to whichever page's canvas the user is
        // actually drawing on right now — `PencilToolManager`'s external
        // API (canUndo/canRedo/undo()/redo(), already used unchanged by
        // `PencilToolbar`) doesn't need to know there's more than one canvas.
        toolManager?.attach(canvasView)
        onStrokeBegan?()
    }

    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        toolManager?.refreshUndoState()
    }
}
