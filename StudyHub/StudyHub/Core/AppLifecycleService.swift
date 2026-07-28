import SwiftData
import SwiftUI

@MainActor
final class AppLifecycleService: AppLifecycleServicing {
    private let appState: AppState
    private let modelContainer: ModelContainer

    init(appState: AppState, modelContainer: ModelContainer) {
        self.appState = appState
        self.modelContainer = modelContainer
    }

    func handle(scenePhase: ScenePhase) {
        appState.update(scenePhase: scenePhase)

        if scenePhase == .background {
            do {
                try modelContainer.mainContext.save()
            } catch {
                assertionFailure("Failed to save model context on backgrounding: \(error)")
            }
        }
    }
}
