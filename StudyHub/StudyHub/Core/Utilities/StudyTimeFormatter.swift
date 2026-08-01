import Foundation

/// Formats a minute count for display, switching to hours once it's large
/// enough that minutes alone stop being readable (Analytics/Home Study
/// Overview) — under an hour shows as "42m", an hour or more shows as
/// "2h 15m" (or just "2h" when there's no remainder).
enum StudyTimeFormatter {
    static func label(minutes: Int) -> String {
        guard minutes >= 60 else { return "\(minutes)m" }
        let hours = minutes / 60
        let remainder = minutes % 60
        return remainder == 0 ? "\(hours)h" : "\(hours)h \(remainder)m"
    }

    static func label(minutes: Double) -> String {
        label(minutes: Int(minutes.rounded()))
    }
}
