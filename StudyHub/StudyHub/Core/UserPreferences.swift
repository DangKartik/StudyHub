import Foundation
import SwiftUI

/// Follows the system appearance unless explicitly overridden — mirrors
/// what `.preferredColorScheme(nil)` already means, just as an explicit,
/// user-facing choice in Settings.
enum AppearancePreference: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    /// `nil` tells SwiftUI "don't override — follow the system," matching
    /// `.preferredColorScheme`'s own `ColorScheme?` parameter type exactly.
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

/// App-wide display preferences the user can change in Settings — deliberately
/// separate from `AppState` (runtime state derived from the model graph,
/// like the active Semester) since these are plain UI preferences with no
/// SwiftData backing at all, persisted via `UserDefaults`.
@MainActor
@Observable
final class UserPreferences {
    private static let weekStartsOnMondayKey = "weekStartsOnMonday"
    private static let appearanceKey = "appearancePreference"
    private static let userNameKey = "userName"
    private static let defaultLectureDurationMinutesKey = "defaultLectureDurationMinutes"

    private let defaults: UserDefaults

    /// Defaults to Monday — matches how most calendar apps outside the US
    /// lay out a week, and this project's own stated preference. Anyone who
    /// wants Sunday-first can switch it in Settings.
    var weekStartsOnMonday: Bool {
        didSet {
            defaults.set(weekStartsOnMonday, forKey: Self.weekStartsOnMondayKey)
        }
    }

    var appearance: AppearancePreference {
        didSet {
            defaults.set(appearance.rawValue, forKey: Self.appearanceKey)
        }
    }

    /// Shown in Home's greeting ("Good morning, Kartik") — empty means no
    /// name has been set yet, in which case the greeting just omits it.
    var userName: String {
        didSet {
            defaults.set(userName, forKey: Self.userNameKey)
        }
    }

    /// How long a new Lecture's End Time defaults to after Start Time —
    /// used only when creating a Lecture (see `LectureFormView`). Defaults
    /// to 60, a plain hour-long class being the most common case.
    var defaultLectureDurationMinutes: Int {
        didSet {
            defaults.set(defaultLectureDurationMinutes, forKey: Self.defaultLectureDurationMinutesKey)
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if defaults.object(forKey: Self.weekStartsOnMondayKey) == nil {
            weekStartsOnMonday = true
        } else {
            weekStartsOnMonday = defaults.bool(forKey: Self.weekStartsOnMondayKey)
        }

        if let rawValue = defaults.string(forKey: Self.appearanceKey), let stored = AppearancePreference(rawValue: rawValue) {
            appearance = stored
        } else {
            appearance = .system
        }

        userName = defaults.string(forKey: Self.userNameKey) ?? ""

        if defaults.object(forKey: Self.defaultLectureDurationMinutesKey) == nil {
            defaultLectureDurationMinutes = 60
        } else {
            defaultLectureDurationMinutes = defaults.integer(forKey: Self.defaultLectureDurationMinutesKey)
        }
    }

    /// A `Calendar` configured to agree with this preference — pass this
    /// (not `Calendar.current`) anywhere "start of week"/"which day is
    /// first" matters, so every screen stays consistent with the same
    /// setting. `firstWeekday`: 1 = Sunday, 2 = Monday (`Calendar`'s own
    /// numbering, matching `component(.weekday:)`).
    var calendar: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = weekStartsOnMonday ? 2 : 1
        return calendar
    }
}
