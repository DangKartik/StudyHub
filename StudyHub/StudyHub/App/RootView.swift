import SwiftUI

struct RootView: View {
    let appState: AppState
    let navigationRouter: NavigationRouter

    var body: some View {
        AppShellView(navigationRouter: navigationRouter)
    }
}
