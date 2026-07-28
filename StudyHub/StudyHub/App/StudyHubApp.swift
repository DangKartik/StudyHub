import SwiftUI

@main
struct StudyHubApp: App {
    @Environment(\.scenePhase) private var scenePhase

    @State private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            RootView(appState: container.appState)
        }
        .onChange(of: scenePhase, initial: true) { _, phase in
            container.handle(scenePhase: phase)
        }
    }
}
