import Foundation

enum SidebarDestination: String, CaseIterable, Identifiable, Hashable {
    case home
    case courses
    case calendar
    case studyMode
    case flashcards
    case notes
    case statistics
    case resources
    case search
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .courses: return "Courses"
        case .calendar: return "Calendar"
        case .studyMode: return "Study Mode"
        case .flashcards: return "Flashcards"
        case .notes: return "Notes"
        case .statistics: return "Statistics"
        case .resources: return "Resources"
        case .search: return "Search"
        case .settings: return "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .home: return "house.fill"
        case .courses: return "book.closed.fill"
        case .calendar: return "calendar"
        case .studyMode: return "brain.head.profile"
        case .flashcards: return "rectangle.stack.fill"
        case .notes: return "note.text"
        case .statistics: return "chart.bar.fill"
        case .resources: return "folder.fill"
        case .search: return "magnifyingglass"
        case .settings: return "gearshape.fill"
        }
    }
}
