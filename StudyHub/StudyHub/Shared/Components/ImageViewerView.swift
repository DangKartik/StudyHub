import SwiftUI

/// Reusable, owner-agnostic image viewer — mirrors `PDFViewerView`'s shape
/// (plain source string plus `attachment:`/`resource:` convenience inits)
/// but deliberately much simpler: no markup, no page navigation, just
/// pinch-to-zoom, pan-once-zoomed, and a share button — everything an
/// attached photo actually needs.
struct ImageViewerView: View {
    let title: String
    let sourceURL: String

    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    private var image: UIImage? {
        UIImage(contentsOfFile: sourceURL)
    }

    init(title: String, sourceURL: String) {
        self.title = title
        self.sourceURL = sourceURL
    }

    init(attachment: Attachment) {
        self.init(title: attachment.filename, sourceURL: attachment.url)
    }

    init(resource: Resource) {
        self.init(title: resource.title, sourceURL: resource.url)
    }

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(zoomAndPanGesture)
                    .onTapGesture(count: 2, perform: resetOrZoom)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
            } else {
                StudyHubEmptyState(
                    icon: "photo",
                    title: "Image Unavailable",
                    message: "This image could not be loaded."
                )
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Presented via `.fullScreenCover` (see callers), so there's no
            // automatic back button/swipe-back — this Close button is the
            // only way out, same reasoning as `PDFViewerView`'s.
            ToolbarItem(placement: .topBarLeading) {
                Button("Close") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .primaryAction) {
                ShareLink(item: URL(fileURLWithPath: sourceURL))
            }
        }
    }

    private var zoomAndPanGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = min(max(lastScale * value, 1), 5)
            }
            .onEnded { _ in
                lastScale = scale
            }
            .simultaneously(with:
                DragGesture()
                    .onChanged { value in
                        guard scale > 1 else { return }
                        offset = CGSize(
                            width: lastOffset.width + value.translation.width,
                            height: lastOffset.height + value.translation.height
                        )
                    }
                    .onEnded { _ in
                        lastOffset = offset
                    }
            )
    }

    private func resetOrZoom() {
        withAnimation(.spring(response: 0.3)) {
            if scale > 1 {
                scale = 1
                lastScale = 1
                offset = .zero
                lastOffset = .zero
            } else {
                scale = 2
                lastScale = 2
            }
        }
    }
}
