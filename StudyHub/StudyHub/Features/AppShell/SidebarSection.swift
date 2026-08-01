import Foundation

struct SidebarSection: Identifiable {
    let id: String
    let title: String?
    let destinations: [SidebarDestination]
}

extension SidebarSection {
    static let all: [SidebarSection] = [
        SidebarSection(id: "primary", title: nil, destinations: [.home, .courses, .calendar]),
        SidebarSection(id: "learning", title: "Learning", destinations: [.studyMode, .flashcards, .activeRecall, .notes]),
        SidebarSection(id: "analytics", title: "Analytics", destinations: [.statistics]),
        SidebarSection(id: "system", title: nil, destinations: [.search, .settings])
    ]
}
