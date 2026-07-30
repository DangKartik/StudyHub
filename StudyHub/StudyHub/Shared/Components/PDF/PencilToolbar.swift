import PencilKit
import SwiftUI

/// Drawing tools available in the custom markup toolbar. Deliberately
/// excludes "Brush" — see the Phase 3N.6.1A report for the reasoning.
enum PencilToolKind: CaseIterable {
    case pen
    case pencil
    case highlighter
    case lasso
    case eraser

    var label: String {
        switch self {
        case .pencil: return "Pencil"
        case .pen: return "Pen"
        case .highlighter: return "Highlighter"
        case .lasso: return "Lasso"
        case .eraser: return "Eraser"
        }
    }

    var systemImage: String {
        switch self {
        case .pencil: return "pencil"
        case .pen: return "pencil.tip"
        case .highlighter: return "highlighter"
        case .lasso: return "lasso"
        case .eraser: return "eraser"
        }
    }

    /// Only ink tools take on the selected ink color's tint — Lasso and
    /// Eraser don't draw a stroke, so a color has no meaning for them.
    var supportsInkSettings: Bool {
        switch self {
        case .pencil, .pen, .highlighter: return true
        case .lasso, .eraser: return false
        }
    }

    /// Every drawing tool except Lasso has a thickness worth adjusting —
    /// Eraser's floating settings panel just omits the Opacity slider
    /// (handled in `PencilToolbar.settingsPanel`), since erasing has no
    /// concept of opacity.
    var supportsThicknessSettings: Bool {
        switch self {
        case .pencil, .pen, .highlighter, .eraser: return true
        case .lasso: return false
        }
    }

    func makePKTool(color: Color, thickness: CGFloat, opacity: Double) -> PKTool {
        // `UIColor(Color)` bridging proved unreliable for at least one fixed
        // color (black rendered as white) even after forcing a fixed trait
        // collection — rather than keep guessing at why that legacy bridge
        // misbehaves, this bypasses it entirely: `Color.resolve(in:)` hands
        // back literal linear RGB components directly from SwiftUI's own
        // color model, which are then gamma-corrected into real sRGB before
        // constructing the `UIColor`. Deterministic regardless of trait
        // collection, color space, or appearance mode.
        let inkColor = color.pencilKitColor(opacity: opacity)
        switch self {
        case .pencil: return PKInkingTool(.pencil, color: inkColor, width: thickness)
        case .pen: return PKInkingTool(.pen, color: inkColor, width: thickness)
        case .highlighter: return PKInkingTool(.marker, color: inkColor, width: thickness)
        case .lasso: return PKLassoTool()
        // `.fixedWidthBitmap` (unlike plain `.bitmap`) erases a fixed-size
        // area rather than scaling erase radius with pencil pressure/
        // velocity — `width` has a direct, visible effect on Size instead
        // of being a loose baseline that pressure mostly overrides.
        case .eraser: return PKEraserTool(.fixedWidthBitmap, width: thickness)
        }
    }
}

private extension Color {
    /// Converts to a `UIColor` for PencilKit via `Color.resolve(in:)`'s
    /// literal linear RGB components — gamma-corrected to sRGB — instead of
    /// the legacy `UIColor(Color)` bridge, which proved unreliable for at
    /// least one fixed color. Deterministic: doesn't depend on trait
    /// collection, environment, or appearance mode at the point it's read.
    func pencilKitColor(opacity: Double) -> UIColor {
        let resolved = resolve(in: EnvironmentValues())
        return UIColor(
            red: CGFloat(Self.srgbComponent(fromLinear: resolved.linearRed)),
            green: CGFloat(Self.srgbComponent(fromLinear: resolved.linearGreen)),
            blue: CGFloat(Self.srgbComponent(fromLinear: resolved.linearBlue)),
            alpha: CGFloat(opacity)
        )
    }

    private static func srgbComponent(fromLinear linear: Float) -> Float {
        let clamped = max(0, min(1, linear))
        return clamped <= 0.0031308
            ? clamped * 12.92
            : 1.055 * pow(clamped, 1 / 2.4) - 0.055
    }
}

/// The fixed color swatch set requested for the markup toolbar. "Custom" is
/// handled separately by `MulticolorSwatchIcon`, not a case here.
enum PencilSwatch: CaseIterable, Identifiable {
    case white
    case blue
    case green
    case yellow
    case red

    var id: Self { self }

    var color: Color {
        switch self {
        case .white: return .white
        case .blue: return .blue
        case .green: return .green
        case .yellow: return .yellow
        case .red: return .red
        }
    }

    var label: String {
        switch self {
        case .white: return "White"
        case .blue: return "Blue"
        case .green: return "Green"
        case .yellow: return "Yellow"
        case .red: return "Red"
        }
    }
}

private struct SwatchAnchorKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

/// Which top corner the collapsed markup toolbar is docked to. Not a free
/// position — the collapsed circle is only ever at one of these two fixed
/// spots, chosen by the direction the expanded toolbar was pushed.
enum ToolbarCollapseSide {
    case left
    case right
}

/// Custom Apple Notes–style markup toolbar. Not built on `PKToolPicker` — see
/// the Phase 3N.6.1 audit for why the exact single-row, inline-color layout
/// isn't achievable through the system tool picker. Purely presentational:
/// tool selection, per-tool appearance, and undo/redo all live in
/// `PencilToolManager` (Phase 3N.6.3) — this view only reads/writes through
/// it and owns UI-only state (collapse, settings-panel visibility, color-
/// picker visibility) itself.
struct PencilToolbar: View {
    let toolManager: PencilToolManager
    @Binding var isCollapsed: Bool
    @Binding var settingsTool: PencilToolKind?
    @Binding var isShowingColorPicker: Bool
    @Binding var collapseSide: ToolbarCollapseSide

    @State private var swatchAnchor: CGRect = .zero

    private var isCustomColorSelected: Bool {
        !PencilSwatch.allCases.map(\.color).contains(toolManager.selectedColor)
    }

    private var selectedColorBinding: Binding<Color> {
        Binding(get: { toolManager.selectedColor }, set: { toolManager.selectedColor = $0 })
    }

    private var thicknessBinding: Binding<CGFloat> {
        Binding(get: { toolManager.thickness }, set: { toolManager.thickness = $0 })
    }

    private var opacityBinding: Binding<Double> {
        Binding(get: { toolManager.opacity }, set: { toolManager.opacity = $0 })
    }

    var body: some View {
        // `GeometryReader`'s content is placed in its top-*leading* corner
        // whenever that content doesn't itself claim the reader's full
        // width — a `ZStack(alignment: .top)` around unconstrained content
        // never gets the chance to apply its own centering, which is why
        // the toolbar once rendered top-left instead of centered.
        // `HStack { Spacer(); content; Spacer() }` sidesteps that entirely:
        // `Spacer()` is greedy, so the row always fills the full width it's
        // offered, and *then* it centers (or edge-docks) `content` within
        // that width — no reliance on a parent's sizing behavior at all.
        //
        // Collapse/expand uses a plain conditional swap with a simple
        // scale+opacity transition — no sliding, no offset, no spring-driven
        // travel. A prior custom-motion attempt (crossfading a permanently
        // mounted pair with `offset`/`scaleEffect`) is reverted here in
        // favor of this simpler, stable behavior.
        ZStack(alignment: .top) {
            if isCollapsed {
                HStack {
                    if collapseSide == .right { Spacer() }
                    collapsedButton
                    if collapseSide == .left { Spacer() }
                }
                .padding(.top, 24)
                .padding(.horizontal, 16)
                .transition(.scale.combined(with: .opacity))
            } else {
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        expandedToolbar
                            .gesture(collapseSwipeGesture)
                        if let settingsTool, settingsTool.supportsThicknessSettings {
                            settingsPanel
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                    Spacer()
                }
                .padding(.top, 24)
                .transition(.scale.combined(with: .opacity))

                if isShowingColorPicker {
                    GeometryReader { geometry in
                        colorPickerPopover
                            .position(
                                x: min(max(swatchAnchor.midX, 100), geometry.size.width - 100),
                                y: swatchAnchor.maxY + 8 + 86
                            )
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isCollapsed)
        .animation(.easeInOut(duration: 0.2), value: settingsTool)
        .animation(.easeInOut(duration: 0.2), value: isShowingColorPicker)
        .coordinateSpace(name: "pencilToolbarSpace")
        .onPreferenceChange(SwatchAnchorKey.self) { swatchAnchor = $0 }
    }

    private var expandedToolbar: some View {
        HStack(spacing: 14) {
            Button(action: toolManager.undo) {
                Image(systemName: "arrow.uturn.backward")
            }
            .foregroundStyle(toolManager.canUndo ? Color.accentColor : Color.gray.opacity(0.5))
            .disabled(!toolManager.canUndo)
            .accessibilityLabel("Undo")

            Button(action: toolManager.redo) {
                Image(systemName: "arrow.uturn.forward")
            }
            .foregroundStyle(toolManager.canRedo ? Color.accentColor : Color.gray.opacity(0.5))
            .disabled(!toolManager.canRedo)
            .accessibilityLabel("Redo")

            Divider().frame(height: 22)

            ForEach(PencilToolKind.allCases, id: \.self) { tool in
                toolButton(tool)
            }

            Divider().frame(height: 22)

            ForEach(PencilSwatch.allCases) { swatch in
                swatchButton(swatch)
            }
            customColorSwatchButton

            Divider().frame(height: 22)

            Button {
                isCollapsed = true
            } label: {
                Image(systemName: "arrow.down.right.and.arrow.up.left")
            }
            .accessibilityLabel("Collapse Toolbar")
        }
        .font(.system(size: 17, weight: .medium))
        .foregroundStyle(.primary)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.ultraThickMaterial, in: Capsule())
        .overlay(Capsule().strokeBorder(Color.primary.opacity(0.1), lineWidth: 1))
        .shadow(color: .black.opacity(0.2), radius: 6, y: 2)
    }

    private func toolButton(_ tool: PencilToolKind) -> some View {
        Image(systemName: tool.systemImage)
            .foregroundStyle(tintColor(for: tool))
            .frame(width: 30, height: 30)
            .background(
                tool == toolManager.selectedTool ? Color.primary.opacity(0.14) : .clear,
                in: Circle()
            )
            .contentShape(Circle())
            .onTapGesture {
                handleToolTap(tool)
            }
            .accessibilityLabel(tool.label)
            .accessibilityAddTraits(.isButton)
    }

    /// Single tap: tapping the tool that's already selected toggles its
    /// settings panel open/closed; tapping a different tool switches to it
    /// and closes any open settings panel. Replaces Phase 3N.6.1B's
    /// double-tap gesture per this phase's explicit requirement.
    private func handleToolTap(_ tool: PencilToolKind) {
        isShowingColorPicker = false
        if toolManager.selectedTool == tool {
            guard tool.supportsThicknessSettings else { return }
            settingsTool = (settingsTool == tool) ? nil : tool
        } else {
            toolManager.selectedTool = tool
            settingsTool = nil
        }
    }

    private func tintColor(for tool: PencilToolKind) -> Color {
        guard tool == toolManager.selectedTool else { return .primary.opacity(0.65) }
        return tool.supportsInkSettings ? toolManager.selectedColor : .primary
    }

    private func swatchButton(_ swatch: PencilSwatch) -> some View {
        Circle()
            .fill(swatch.color)
            .frame(width: 22, height: 22)
            .overlay(
                Circle().stroke(Color.primary.opacity(0.3), lineWidth: swatch == .white ? 1 : 0)
            )
            .overlay(
                Circle()
                    .stroke(Color.accentColor, lineWidth: toolManager.selectedColor == swatch.color ? 2 : 0)
                    .padding(-3)
            )
            .contentShape(Circle())
            .onTapGesture { toolManager.selectedColor = swatch.color }
            .accessibilityLabel(swatch.label)
            .accessibilityAddTraits(.isButton)
    }

    /// Anchors `colorPickerPopover` directly below this icon (Phase
    /// 3N.6.1C requirement) by publishing this button's own frame, in the
    /// toolbar's coordinate space, via `SwatchAnchorKey`.
    private var customColorSwatchButton: some View {
        MulticolorSwatchIcon(isSelected: isCustomColorSelected)
            .frame(width: 22, height: 22)
            .background(
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: SwatchAnchorKey.self,
                        value: proxy.frame(in: .named("pencilToolbarSpace"))
                    )
                }
            )
            .contentShape(Circle())
            .onTapGesture {
                settingsTool = nil
                isShowingColorPicker.toggle()
            }
            .accessibilityLabel("Custom Color")
            .accessibilityAddTraits(.isButton)
    }

    private var collapsedButton: some View {
        Button {
            isCollapsed = false
        } label: {
            Image(systemName: toolManager.selectedTool.systemImage)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(toolManager.selectedTool.supportsInkSettings ? toolManager.selectedColor : .primary)
                .frame(width: 44, height: 44)
                .background(.ultraThickMaterial, in: Circle())
                .overlay(Circle().strokeBorder(Color.primary.opacity(0.1), lineWidth: 1))
                .shadow(color: .black.opacity(0.2), radius: 6, y: 2)
        }
        .accessibilityLabel("Expand Markup Toolbar")
    }

    /// Pushing the expanded toolbar left or right past a small threshold
    /// collapses it to that edge; anything short of the threshold leaves it
    /// centered and expanded, exactly where it started.
    private var collapseSwipeGesture: some Gesture {
        DragGesture(minimumDistance: 20)
            .onEnded { value in
                if value.translation.width > 40 {
                    collapseSide = .right
                    isCollapsed = true
                } else if value.translation.width < -40 {
                    collapseSide = .left
                    isCollapsed = true
                }
            }
    }

    private var settingsPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text(settingsTool == .eraser ? "Size" : "Thickness")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
                // A hardcoded 0...20 range for Eraser was silently getting
                // clamped — `.fixedWidthBitmap`'s actual valid width range
                // doesn't necessarily start at (or even include) the ink
                // tools' 1...20 stroke-width scale, so every value in that
                // guessed range could resolve to the same clamped size,
                // which is exactly why moving the slider had no visible
                // effect. Using PencilKit's own authoritative range instead
                // guarantees every position on the slider is a real, valid,
                // distinct eraser size.
                Slider(
                    value: thicknessBinding,
                    in: settingsTool == .eraser
                        ? PKEraserTool.EraserType.fixedWidthBitmap.validWidthRange
                        : 1...20
                )
            }
            // Eraser has no concept of opacity — only its size slider
            // shows, same floating panel as the ink tools.
            if settingsTool != .eraser {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Opacity")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.primary)
                    Slider(value: opacityBinding, in: 0.1...1)
                }
            }
        }
        .padding(16)
        .frame(width: 220)
        .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.primary.opacity(0.1), lineWidth: 1))
        .shadow(color: .black.opacity(0.2), radius: 8, y: 2)
    }

    private var colorPickerPopover: some View {
        CustomColorPickerPanel(selectedColor: selectedColorBinding)
            .padding(12)
            .frame(width: 180, height: 172)
            .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.primary.opacity(0.1), lineWidth: 1))
            .shadow(color: .black.opacity(0.2), radius: 8, y: 2)
    }
}
