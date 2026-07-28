import SwiftData
import SwiftUI

@MainActor
final class AppContainer {
    let appState: AppState
    let modelContainer: ModelContainer

    private let appLifecycleService: any AppLifecycleServicing

    init() {
        let appState = AppState()

        self.appState = appState
        self.modelContainer = ModelContainerFactory.makeContainer()
        appLifecycleService = AppLifecycleService(appState: appState)
    }

    func handle(scenePhase: ScenePhase) {
        appLifecycleService.handle(scenePhase: scenePhase)
    }
}
