import SwiftUI

struct SidebarView: View {
    @Bindable var router: NavigationRouter

    var body: some View {
        List(selection: $router.selectedDestination) {
            ForEach(SidebarSection.all) { section in
                if let title = section.title {
                    Section(title) {
                        rows(for: section)
                    }
                } else {
                    Section {
                        rows(for: section)
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("StudyHub")
    }

    @ViewBuilder
    private func rows(for section: SidebarSection) -> some View {
        ForEach(section.destinations) { destination in
            Label(destination.title, systemImage: destination.systemImage)
                .tag(destination)
                .accessibilityLabel(destination.title)
                .accessibilityHint("Double tap to open \(destination.title).")
        }
    }
}
