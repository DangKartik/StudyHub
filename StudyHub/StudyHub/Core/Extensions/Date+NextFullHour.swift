import Foundation

extension Date {
    /// Rounds a date forward to the next full hour — used as the default
    /// Start Time for a brand-new Lecture or Assessment. Already-on-the-hour
    /// is left as-is rather than jumping forward a full hour unnecessarily.
    /// Shared by `LectureFormView` and `AssessmentFormView` (previously
    /// duplicated as a private helper on `LectureFormView` alone).
    static func nextFullHour(from date: Date) -> Date {
        let calendar = Calendar.current
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        guard minute != 0 || second != 0 else { return date }
        guard let flooredToHour = calendar.date(bySettingHour: calendar.component(.hour, from: date), minute: 0, second: 0, of: date) else {
            return date
        }
        return calendar.date(byAdding: .hour, value: 1, to: flooredToHour) ?? date
    }
}
