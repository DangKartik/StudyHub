import SwiftUI

/// Phase 5 — `TextEditor` has no built-in placeholder support (unlike
/// `TextField`), so a fresh multi-line field renders as a blank box with no
/// hint at all. This overlays faint placeholder text that disappears the
/// moment typing starts, matching how every `TextField` in these same forms
/// already behaves.
struct PlaceholderTextEditor: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundStyle(Color(uiColor: .placeholderText))
                    .padding(.top, 8)
                    .padding(.leading, 5)
                    .allowsHitTesting(false)
            }
            TextEditor(text: $text)
        }
    }
}
