import SwiftUI
import UIKit

extension Color {
    init?(hex: String) {
        let sanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")

        guard sanitized.count == 6, let rgbValue = UInt64(sanitized, radix: 16) else {
            return nil
        }

        let red = Double((rgbValue & 0xFF0000) >> 16) / 255
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255
        let blue = Double(rgbValue & 0x0000FF) / 255

        self.init(red: red, green: green, blue: blue)
    }

    var hexString: String {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let r = Int((red * 255).rounded())
        let g = Int((green * 255).rounded())
        let b = Int((blue * 255).rounded())

        return String(format: "#%02X%02X%02X", r, g, b)
    }

    /// Resolves a stored course color string to a `Color`.
    ///
    /// Supports both hex strings (the current storage format) and the
    /// legacy preset names used before custom colors were supported,
    /// falling back to gray for anything unrecognized.
    static func courseColor(from stored: String) -> Color {
        if let hexColor = Color(hex: stored) {
            return hexColor
        }
        return legacyPresetColor(named: stored) ?? .gray
    }

    private static func legacyPresetColor(named name: String) -> Color? {
        switch name {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "brown": return .brown
        case "pink": return .pink
        case "gray": return .gray
        default: return nil
        }
    }
}
