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
                ListSectionHeaderLabel(title: "Profile", icon: "person.fill", tint: .blue)
            } footer: {
                Text("Shown in Home's greeting. Leave blank to skip it.")
            }

            Section {
                Picker("Appearance", selection: Binding(
                    get: { userPreferences.appearance },
                    set: { userPreferences.appearance = $0 }
                )) {
                    ForEach(AppearancePreference.allCases) { option in
                        Text(option.label).tag(option)
                    }
                }
                .pickerStyle(.segmented)
            } header: {
                ListSectionHeaderLabel(title: "Appearance", icon: "circle.righthalf.filled", tint: .purple)
            }

            Section {
                Toggle("Week Starts on Monday", isOn: Binding(
                    get: { userPreferences.weekStartsOnMonday },
                    set: { userPreferences.weekStartsOnMonday = $0 }
                ))
            } header: {
                ListSectionHeaderLabel(title: "Calendar", icon: "calendar", tint: .orange)
            } footer: {
                Text("Controls how \"This Week\" and the Analytics heatmap group days into weeks. Off uses Sunday as the first day instead.")
            }

            Section {
                Picker("Default Duration", selection: Binding(
                    get: { userPreferences.defaultLectureDurationMinutes },
                    set: { userPreferences.defaultLectureDurationMinutes = $0 }
                )) {
                    ForEach(Self.lectureDurationOptions, id: \.self) { minutes in
                        Text(StudyTimeFormatter.label(minutes: minutes)).tag(minutes)
                    }
                }
            } header: {
                ListSectionHeaderLabel(title: "Lectures", icon: "list.bullet", tint: .pink)
            } footer: {
                Text("New lectures default to starting at the next full hour and ending this long after.")
            }

            Section {
                LabeledContent("Version", value: appVersionText)
            } header: {
                ListSectionHeaderLabel(title: "About", icon: "info.circle.fill", tint: .gray)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    private static let lectureDurationOptions = [30, 45, 60, 75, 90, 105, 120]

    private var appVersionText: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
        return "\(version) (\(build))"
    }
}
