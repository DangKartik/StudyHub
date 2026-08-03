import SwiftUI

/// Phase 5 — gained an optional primary action so an empty screen can offer
/// a real path forward (e.g. "Add Course") instead of just icon/title/
/// message with the only way out being a toolbar button the user has to
/// notice on their own. `actionTitle`/`action` are both optional and
/// default to nil, so every existing call site is unaffected.
struct StudyHubEmptyState: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: icon)
        } description: {
            Text(message)
        } actions: {
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
            }
        }
    }
}
