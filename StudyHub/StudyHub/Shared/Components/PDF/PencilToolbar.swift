import PencilKit
import SwiftUI

/// Drawing tools available in the custom markup toolbar. Deliberately
/// excludes "Brush" — see the Phase 3N.6.1A report for the reasoning.
enum PencilToolKind: CaseIterable {
    case pencil
    case pen
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

    /// Only ink tools have a thickness/opacity to adjust — Lasso and Eraser
    /// don't draw a stroke, so they're excluded from the settings panel and
    /// from taking on the selected ink color's tint.
    var supportsInkSettings: Bool {
        switch self {
        case .pencil, .pen, .highlighter: return true
        case .lasso, .eraser: return false
        }
    }

    func makePKTool(color: Color, thickness: CGFloat, opacity: Double) -> PKTool {
        let inkColor = UIColor(color).withAlphaComponent(opacity)
        switch self {
        case .pencil: return PKInkingTool(.pencil, color: inkColor, width: thickness)
        case .pen: return PKInkingTool(.pen, color: inkColor, width: thickness)
        case .highlighter: return PKInkingTool(.marker, color: inkColor, width: thickness)
        case .lasso: return PKLassoTool()
        case .eraser: return PKEraserTool(.bitmap)
        }
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
/// all real state (`selectedTool`, `selectedColor`, `thickness`, `opacity`)
/// is owned by `PDFViewerView` and passed down as bindings, so there is a
/// single source of truth for the `PKTool` handed to `PencilCanvasView`.
struct PencilToolbar: View {
    @Binding var selectedTool: PencilToolKind
    @Binding var selectedColor: Color
    @Binding var thickness: CGFloat
    @Binding var opacity: Double
    @Binding var isCollapsed: Bool
    @Binding var settingsTool: PencilToolKind?
    @Binding var isShowingColorPicker: Bool
    @Binding var collapseSide: ToolbarCollapseSide
    let controller: PencilCanvasController

    @State private var swatchAnchor: CGRect = .zero

    private var isCustomColorSelected: Bool {
        !PencilSwatch.allCases.map(\.color).contains(selectedColor)
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
                        if let settingsTool, settingsTool.supportsInkSettings {
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
            Button(action: controller.undo) {
                Image(systemName: "arrow.uturn.backward")
            }
            .disabled(!controller.canUndo)
            .accessibilityLabel("Undo")

            Button(action: controller.redo) {
                Image(systemName: "arrow.uturn.forward")
            }
            .disabled(!controller.canRedo)
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
                tool == selectedTool ? Color.primary.opacity(0.14) : .clear,
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
        if selectedTool == tool {
            guard tool.supportsInkSettings else { return }
            settingsTool = (settingsTool == tool) ? nil : tool
        } else {
            selectedTool = tool
            settingsTool = nil
        }
    }

    private func tintColor(for tool: PencilToolKind) -> Color {
        guard tool == selectedTool else { return .primary.opacity(0.65) }
        return tool.supportsInkSettings ? selectedColor : .primary
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
                    .stroke(Color.accentColor, lineWidth: selectedColor == swatch.color ? 2 : 0)
                    .padding(-3)
            )
            .contentShape(Circle())
            .onTapGesture { selectedColor = swatch.color }
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
            Image(systemName: selectedTool.systemImage)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(selectedTool.supportsInkSettings ? selectedColor : .primary)
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
                Text("Thickness")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
                Slider(value: $thickness, in: 1...20)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text("Opacity")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
                Slider(value: $opacity, in: 0.1...1)
            }
        }
        .padding(16)
        .frame(width: 220)
        .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.primary.opacity(0.1), lineWidth: 1))
        .shadow(color: .black.opacity(0.2), radius: 8, y: 2)
    }

    private var colorPickerPopover: some View {
        CustomColorPickerPanel(selectedColor: $selectedColor)
            .padding(12)
            .frame(width: 180, height: 172)
            .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.primary.opacity(0.1), lineWidth: 1))
            .shadow(color: .black.opacity(0.2), radius: 8, y: 2)
    }
}
