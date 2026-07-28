import SwiftUI

@MainActor
final class AppContainer {
    let appState: AppState

    private let appLifecycleService: any AppLifecycleServicing

    init() {
        let appState = AppState()

        self.appState = appState
        appLifecycleService = AppLifecycleService(appState: appState)
    }

    func handle(scenePhase: ScenePhase) {
        appLifecycleService.handle(scenePhase: scenePhase)
    }
}
