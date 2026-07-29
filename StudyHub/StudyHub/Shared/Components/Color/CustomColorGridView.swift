import SwiftUI

struct CustomColorGridView: View {
    @Binding var selectedColor: Color
    @Environment(\.dismiss) private var dismiss

    @State private var previewColor: Color

    init(selectedColor: Binding<Color>) {
        _selectedColor = selectedColor
        _previewColor = State(initialValue: selectedColor.wrappedValue)
    }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 6)

    private var swatches: [Color] {
        var colors: [Color] = []
        for step in 0..<12 {
            let hue = Double(step) / 12
            for brightness in [0.9, 0.7, 0.5] {
                colors.append(Color(hue: hue, saturation: 0.75, brightness: brightness))
            }
        }
        for whiteLevel in stride(from: 0.95, through: 0.05, by: -0.15) {
            colors.append(Color(white: whiteLevel))
        }
        return colors
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(Array(swatches.enumerated()), id: \.offset) { _, swatch in
                            Button {
                                previewColor = swatch
                            } label: {
                                Circle()
                                    .fill(swatch)
                                    .frame(width: 36, height: 36)
                                    .overlay {
                                        Circle()
                                            .stroke(Color.primary, lineWidth: swatch.hexString == previewColor.hexString ? 3 : 0)
                                    }
                                    .overlay {
                                        if swatch.hexString == previewColor.hexString {
                                            Image(systemName: "checkmark")
                                                .font(.caption.bold())
                                                .foregroundStyle(.white)
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Custom Color")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        selectedColor = previewColor
                        dismiss()
                    }
                }
            }
        }
    }
}
