import SwiftUI

/// Wired to the sidebar's existing `.settings` destination, which (like
/// `.statistics` before Phase 4.5 and `.resources` before it was removed)
/// had no real screen behind it. Starts minimal — the one setting that
/// actually exists right now is the week-start preference (requested
/// alongside the Analytics heatmap); more can be added here as they come up.
struct SettingsView: View {
    let userPreferences: UserPreferences

    var body: some View {
        Form {
            Section {
                TextField("Your Name", text: Binding(
                    get: { userPreferences.userName },
                    set: { userPreferences.userName = $0 }
                ))
            } header: {
                Text("Profile")
            } footer: {
                Text("Shown in Home's greeting. Leave blank to skip it.")
            }

            Section("Appearance") {
                Picker("Appearance", selection: Binding(
                    get: { userPreferences.appearance },
                    set: { userPreferences.appearance = $0 }
                )) {
                    ForEach(AppearancePreference.allCases) { option in
                        Text(option.label).tag(option)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section {
                Toggle("Week Starts on Monday", isOn: Binding(
                    get: { userPreferences.weekStartsOnMonday },
                    set: { userPreferences.weekStartsOnMonday = $0 }
                ))
            } header: {
                Text("Calendar")
            } footer: {
                Text("Controls how \"This Week\" and the Analytics heatmap group days into weeks. Off uses Sunday as the first day instead.")
            }

            Section("About") {
                LabeledContent("Version", value: appVersionText)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var appVersionText: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
        return "\(version) (\(build))"
    }
}
