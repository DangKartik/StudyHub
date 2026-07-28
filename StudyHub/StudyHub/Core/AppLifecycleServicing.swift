import SwiftUI

@MainActor
protocol AppLifecycleServicing {
    func handle(scenePhase: ScenePhase)
}
