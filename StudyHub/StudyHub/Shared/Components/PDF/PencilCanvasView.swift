import PencilKit
import SwiftUI

/// Owns the live reference to the on-screen `PKCanvasView` so tool changes and
/// undo/redo can be driven from SwiftUI state without SwiftUI re-creating the
/// canvas itself. A plain, view-local UI controller — not a DI-registered
/// service, since nothing outside this markup UI needs it (mirrors how
/// `@State` would own a value type, adapted for a reference-type UIKit view).
@MainActor
@Observable
final class PencilCanvasController {
    private(set) weak var canvasView: PKCanvasView?
    private(set) var canUndo = false
    private(set) var canRedo = false

    func attach(_ canvasView: PKCanvasView) {
        self.canvasView = canvasView
        refreshUndoState()
    }

    func undo() {
        canvasView?.undoManager?.undo()
        refreshUndoState()
    }

    func redo() {
        canvasView?.undoManager?.redo()
        refreshUndoState()
    }

    func refreshUndoState() {
        canUndo = canvasView?.undoManager?.canUndo ?? false
        canRedo = canvasView?.undoManager?.canRedo ?? false
    }
}

/// Thin `UIViewRepresentable` wrapper around `PKCanvasView`, mirroring how
/// `PDFKitRepresentedView` (in `PDFViewerView.swift`) wraps `PDFView` elsewhere
/// in this app. `tool` is pushed onto the canvas on every update rather than
/// mutated from within the controller, so SwiftUI state (`selectedTool` /
/// `selectedColor` / `thickness` / `opacity` in `PDFViewerView`) stays the
/// single source of truth. Drawings are not persisted anywhere — this is
/// foundation-only (Phase 3N.6.1A); the drawing is discarded when the canvas
/// is removed from the view tree.
struct PencilCanvasView: UIViewRepresentable {
    let controller: PencilCanvasController
    let tool: PKTool
    let onStrokeBegan: () -> Void

    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = PKCanvasView()
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        // Apple Pencil draws; finger touches never draw or scroll the canvas
        // itself while Markup is active (see Phase 3N.6.1A input policy note
        // in PDFViewerView.swift) — page-aware scroll-while-marking-up is
        // deferred to the persistence phase.
        canvasView.drawingPolicy = .pencilOnly
        canvasView.isScrollEnabled = false
        canvasView.tool = tool
        canvasView.delegate = context.coordinator
        controller.attach(canvasView)
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.tool = tool
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(controller: controller, onStrokeBegan: onStrokeBegan)
    }

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        private let controller: PencilCanvasController
        private let onStrokeBegan: () -> Void

        init(controller: PencilCanvasController, onStrokeBegan: @escaping () -> Void) {
            self.controller = controller
            self.onStrokeBegan = onStrokeBegan
        }

        func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
            onStrokeBegan()
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            controller.refreshUndoState()
        }
    }
}
