import PDFKit
import SwiftUI

/// Reusable, owner-agnostic PDF viewer. Displays a PDF from any plain URL string
/// (an `Attachment.url` or a `Resource.url`) using native `PDFKit` behavior only —
/// scrolling, pinch-to-zoom, text selection, copy, and page rendering are all
/// inherited from `PDFView` for free. No overlays, gestures, or annotation support
/// are added on top of it.
struct PDFViewerView: View {
    let title: String
    let sourceURL: String
    let pdfService: any PDFServiceProtocol

    @State private var viewModel: PDFViewerViewModel

    init(title: String, sourceURL: String, pdfService: any PDFServiceProtocol) {
        self.title = title
        self.sourceURL = sourceURL
        self.pdfService = pdfService
        _viewModel = State(wrappedValue: PDFViewerViewModel(sourceURL: sourceURL, pdfService: pdfService))
    }

    init(attachment: Attachment, pdfService: any PDFServiceProtocol) {
        self.init(title: attachment.filename, sourceURL: attachment.url, pdfService: pdfService)
    }

    var body: some View {
        Group {
            if let document = viewModel.document {
                PDFKitRepresentedView(document: document)
            } else if let error = viewModel.loadError {
                StudyHubEmptyState(
                    icon: "doc.text.magnifyingglass",
                    title: error.title,
                    message: error.message
                )
            } else {
                ProgressView()
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel.document == nil && viewModel.loadError == nil {
                viewModel.loadDocument()
            }
        }
    }
}

/// Thin `UIViewRepresentable` wrapper around `PDFKit.PDFView`. Configures
/// auto-scaling and continuous vertical paging only — everything else (text
/// selection, copy, native search via `PDFDocument.findString`, page rendering)
/// is `PDFView`'s own default behavior and is left untouched.
private struct PDFKitRepresentedView: UIViewRepresentable {
    let document: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.document = document
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        if uiView.document !== document {
            uiView.document = document
        }
    }
}
