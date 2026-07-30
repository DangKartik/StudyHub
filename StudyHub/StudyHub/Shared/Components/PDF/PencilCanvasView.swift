import PencilKit
import SwiftUI

/// Thin `UIViewRepresentable` wrapper around `PKCanvasView`, mirroring how
/// `PDFKitRepresentedView` (in `PDFViewerView.swift`) wraps `PDFView` elsewhere
/// in this app. `tool` is pushed onto the canvas on every update rather than
/// mutated from within the manager, so `PencilToolManager` (which owns tool
/// selection, per-tool appearance, and undo/redo state) stays the single
/// source of truth. Drawings are not persisted anywhere — the drawing is
/// discarded when the canvas is removed from the view tree.
struct PencilCanvasView: UIViewRepresentable {
    let controller: PencilToolManager
    let tool: PKTool
    let onStrokeBegan: () -> Void

    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = PKCanvasView()
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.isUserInteractionEnabled = true
        // Confirmed root cause of the black/white ink swap: with the app in
        // Dark Mode, PencilKit's own rendering adapts pure black/white ink
        // to the canvas's current appearance (the exact "white draws black,
        // black draws white" symptom) — no `UIColor`/`Color` conversion on
        // our side can prevent that, since it happens inside PencilKit's
        // rendering, not in the color value we hand it. Pinning the
        // canvas's own trait environment to light removes dark mode as a
        // variable for anything PencilKit does internally.
        canvasView.overrideUserInterfaceStyle = .light
        // PencilKit defaults are left untouched (no drawingPolicy,
        // isScrollEnabled unchanged) — the confirmed-working minimal test
        // used none of these restrictions; they'll be reintroduced only
        // once all tools are verified working with them off. See Phase
        // 3N.6.3B/C/E.
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
        private let controller: PencilToolManager
        private let onStrokeBegan: () -> Void

        init(controller: PencilToolManager, onStrokeBegan: @escaping () -> Void) {
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
