import SwiftUI

/// Static multicolor circular swatch icon — the visual affordance for "pick
/// a custom color" used everywhere the app needs it (Pencil markup toolbar,
/// Semester color, Course color, ...). Carries no gesture of its own: a
/// caller that's already a standalone tap target (e.g. one swatch among
/// several) can attach `.onTapGesture` directly; a caller embedding this
/// inside an already-tappable row (e.g. a Form row) can leave it inert and
/// let the row's own gesture drive it, avoiding nested/duplicate gestures.
struct MulticolorSwatchIcon: View {
    var isSelected: Bool = false

    var body: some View {
        Circle()
            .fill(
                AngularGradient(
                    colors: [.red, .yellow, .green, .cyan, .blue, .purple, .red],
                    center: .center
                )
            )
            .overlay(
                Circle()
                    .stroke(Color.accentColor, lineWidth: isSelected ? 2 : 0)
                    .padding(-3)
            )
    }
}

/// Compact, draggable HSB color picker — a saturation/brightness square with
/// a hollow white circle selector, plus a thin hue strip beneath it (a
/// square alone can only vary shades of one hue, so a hue input is the
/// minimum needed to reach the full color space). Both update `selectedColor`
/// live as they're dragged. No background/frame decoration of its own —
/// callers size and present it however fits their context (a floating
/// overlay positioned under a toolbar icon, a `.popover` anchored to a Form
/// row, etc.), so this one view is reusable everywhere a "custom color"
/// affordance is needed instead of duplicating the picker logic.
struct CustomColorPickerPanel: View {
    @Binding var selectedColor: Color

    @State private var hue: Double = 0.6
    @State private var position = CGPoint(x: 0.5, y: 0.5)

    var body: some View {
        VStack(spacing: 10) {
            colorSquare
            hueSlider
        }
        .onAppear {
            seedFromSelectedColor()
        }
    }

    private var colorSquare: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                Rectangle().fill(Color(hue: hue, saturation: 1, brightness: 1))
                LinearGradient(colors: [.white, .clear], startPoint: .leading, endPoint: .trailing)
                LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom)

                Circle()
                    .strokeBorder(Color.white, lineWidth: 3)
                    .frame(width: 22, height: 22)
                    .shadow(radius: 1)
                    .position(
                        x: position.x * geometry.size.width,
                        y: position.y * geometry.size.height
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let x = min(max(value.location.x / geometry.size.width, 0), 1)
                        let y = min(max(value.location.y / geometry.size.height, 0), 1)
                        position = CGPoint(x: x, y: y)
                        updateSelectedColor()
                    }
            )
        }
    }

    private var hueSlider: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                LinearGradient(
                    colors: stride(from: 0.0, through: 1.0, by: 0.02).map {
                        Color(hue: $0, saturation: 1, brightness: 1)
                    },
                    startPoint: .leading,
                    endPoint: .trailing
                )
                Circle()
                    .strokeBorder(Color.white, lineWidth: 3)
                    .frame(width: 18, height: 18)
                    .shadow(radius: 1)
                    .position(x: hue * geometry.size.width, y: geometry.size.height / 2)
            }
            .clipShape(Capsule())
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        hue = min(max(value.location.x / geometry.size.width, 0), 1)
                        updateSelectedColor()
                    }
            )
        }
        .frame(height: 20)
    }

    private func updateSelectedColor() {
        selectedColor = Color(hue: hue, saturation: position.x, brightness: 1 - position.y)
    }

    private func seedFromSelectedColor() {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        UIColor(selectedColor).getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        hue = Double(h)
        position = CGPoint(x: s, y: 1 - b)
    }
}
