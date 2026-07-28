import Observation
import SwiftUI

@MainActor
@Observable
final class AppState {
    private(set) var scenePhase: ScenePhase = .inactive

    var isActive: Bool {
        scenePhase == .active
    }

    func update(scenePhase: ScenePhase) {
        self.scenePhase = scenePhase
    }
}
