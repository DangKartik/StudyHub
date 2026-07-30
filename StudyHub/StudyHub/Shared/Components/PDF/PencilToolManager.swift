import PencilKit
import SwiftUI

/// Per-tool appearance settings — Pencil, Pen, Highlighter, and Eraser each
/// remember their own width (ink tools also remember color/opacity), so
/// switching between them restores what was last set for that specific tool
/// instead of bleeding into one shared value (e.g. Highlighter no longer
/// inherits Pen's thin width). Lasso has no entry — it doesn't draw a
/// stroke, so there's nothing to remember for it.
struct PencilToolSettings {
    var color: Color
    var width: CGFloat
    var opacity: Double
}

/// Owns everything about the active PencilKit tool that isn't toolbar
/// *layout*: which tool is selected, each ink tool's remembered appearance,
/// `PKTool` construction, the live `PKCanvasView` reference, and undo/redo.
/// `PencilToolbar` stays purely presentational — it reads and writes through
/// this manager instead of holding the state itself.
@MainActor
@Observable
final class PencilToolManager {
    var selectedTool: PencilToolKind = .pen

    private var settings: [PencilToolKind: PencilToolSettings] = [
        .pencil: PencilToolSettings(color: .black, width: 4, opacity: 1.0),
        .pen: PencilToolSettings(color: .blue, width: 5, opacity: 1.0),
        .highlighter: PencilToolSettings(color: .yellow, width: 20, opacity: 1.0),
        // Eraser only ever reads `width` (via `PKEraserTool(_:width:)`) —
        // color/opacity here are unused placeholders, kept only so it can
        // share the same settings storage as the ink tools. Starts at
        // `.fixedWidthBitmap`'s own minimum valid width — PencilKit clamps
        // anything below that anyway, so a literal `0` here would just
        // silently become this same value the first time it's read.
        .eraser: PencilToolSettings(
            color: .white,
            width: PKEraserTool.EraserType.fixedWidthBitmap.validWidthRange.lowerBound,
            opacity: 1.0
        )
    ]

    private(set) weak var canvasView: PKCanvasView?
    private(set) var canUndo = false
    private(set) var canRedo = false

    /// Falls back to a harmless default when the selected tool has no
    /// settings entry (Lasso) — `PencilToolKind.makePKTool` never actually
    /// reads color/width/opacity for Lasso, so the fallback value is never
    /// visibly used. Eraser has a real entry (for `width` only — see
    /// `PencilToolSettings`).
    var selectedColor: Color {
        get { settings[selectedTool]?.color ?? .blue }
        set { settings[selectedTool]?.color = newValue }
    }

    var thickness: CGFloat {
        get { settings[selectedTool]?.width ?? 4 }
        set { settings[selectedTool]?.width = newValue }
    }

    var opacity: Double {
        get { settings[selectedTool]?.opacity ?? 1.0 }
        set { settings[selectedTool]?.opacity = newValue }
    }

    var currentTool: PKTool {
        selectedTool.makePKTool(color: selectedColor, thickness: thickness, opacity: opacity)
    }

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
