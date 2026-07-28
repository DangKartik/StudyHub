import Observation
import SwiftUI

@MainActor
@Observable
final class AppState {
    private(set) var scenePhase: ScenePhase = .inactive
    private(set) var activeSemester: Semester?

    var isActive: Bool {
        scenePhase == .active
    }

    func update(scenePhase: ScenePhase) {
        self.scenePhase = scenePhase
    }

    func update(activeSemester: Semester?) {
        self.activeSemester = activeSemester
    }
}
