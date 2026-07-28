import SwiftUI

struct AppShellView: View {
    let navigationRouter: NavigationRouter

    var body: some View {
        NavigationSplitView {
            SidebarView(router: navigationRouter)
        } detail: {
            AppShellDetailView(destination: navigationRouter.selectedDestination)
        }
    }
}
