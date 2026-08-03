import Foundation

extension Reading {
    /// Three tiers, lower `rawValue` = higher display/sort precedence —
    /// shared by every place a Reading's urgency needs to be shown or
    /// sorted (`ReadingListView`'s row badge, `ReadingViewModel`'s list
    /// order, `HomeViewModel`'s Upcoming Readings order), so they can never
    /// disagree with each other.
    enum DueStatus: Int, Comparable {
        case dueToday = 0
        case dueSoon = 1
        case notDue = 2

        static func < (lhs: DueStatus, rhs: DueStatus) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    /// A due date today or already past reads as `.dueToday` (folding
    /// overdue into the same urgent tier rather than a separate label);
    /// anything later is `.dueSoon`; no due date at all is `.notDue`.
    var dueStatus: DueStatus {
        guard let dueDate else { return .notDue }
        let today = Calendar.current.startOfDay(for: .now)
        let due = Calendar.current.startOfDay(for: dueDate)
        return due <= today ? .dueToday : .dueSoon
    }
}
