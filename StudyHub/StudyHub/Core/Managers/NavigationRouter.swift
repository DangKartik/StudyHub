import Observation

@MainActor
@Observable
final class NavigationRouter {
    var selectedDestination: SidebarDestination?

    init(selectedDestination: SidebarDestination? = .home) {
        self.selectedDestination = selectedDestination
    }
}
