import SwiftUI

struct AppShellDetailView: View {
    let destination: SidebarDestination?

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(destination?.title ?? "StudyHub")
        }
    }

    @ViewBuilder
    private var content: some View {
        if let destination {
            StudyHubEmptyState(
                icon: destination.systemImage,
                title: destination.title,
                message: "This section hasn't been built yet."
            )
        } else {
            StudyHubEmptyState(
                icon: "sidebar.left",
                title: "StudyHub",
                message: "Select a section to get started."
            )
        }
    }
}
