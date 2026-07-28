import SwiftUI

@MainActor
final class AppLifecycleService: AppLifecycleServicing {
    private let appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    func handle(scenePhase: ScenePhase) {
        appState.update(scenePhase: scenePhase)
    }
}
