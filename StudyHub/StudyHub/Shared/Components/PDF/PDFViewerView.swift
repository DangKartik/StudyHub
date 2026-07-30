import PDFKit
import PencilKit
import SwiftUI

/// Reusable, owner-agnostic PDF viewer. Displays a PDF from any plain URL string
/// (an `Attachment.url` or a `Resource.url`) using native `PDFKit` behavior only —
/// scrolling, pinch-to-zoom, text selection, copy, and page rendering are all
/// inherited from `PDFView` for free.
///
/// Also hosts the optional Markup mode toolbar (Phase 3N.6.1A): a Summary
/// button (shown only when the caller passes non-nil `summary` text) and a
/// Markup toggle that overlays a `PencilCanvasView` + `PencilToolbar` on top
/// of the PDF. Drawings are **not persisted** in this phase — toggling Markup
/// off discards whatever was drawn.
struct PDFViewerView: View {
    let title: String
    let sourceURL: String
    let summary: String?
    let onSummaryEdit: ((String) -> Void)?
    let pdfService: any PDFServiceProtocol

    @State private var viewModel: PDFViewerViewModel

    @State private var isMarkupActive = false
    @State private var isShowingSummary = false
    @State private var toolManager = PencilToolManager()
    @State private var isToolbarCollapsed = false
    @State private var settingsTool: PencilToolKind?
    @State private var isShowingColorPicker = false
    @State private var toolbarCollapseSide: ToolbarCollapseSide = .right

    init(
        title: String,
        sourceURL: String,
        summary: String? = nil,
        onSummaryEdit: ((String) -> Void)? = nil,
        pdfService: any PDFServiceProtocol
    ) {
        self.title = title
        self.sourceURL = sourceURL
        self.summary = summary
        self.onSummaryEdit = onSummaryEdit
        self.pdfService = pdfService
        _viewModel = State(wrappedValue: PDFViewerViewModel(sourceURL: sourceURL, pdfService: pdfService))
    }

    init(
        attachment: Attachment,
        summary: String? = nil,
        onSummaryEdit: ((String) -> Void)? = nil,
        pdfService: any PDFServiceProtocol
    ) {
        self.init(
            title: attachment.filename,
            sourceURL: attachment.url,
            summary: summary,
            onSummaryEdit: onSummaryEdit,
            pdfService: pdfService
        )
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
        .overlay {
            if isMarkupActive {
                PencilCanvasView(controller: toolManager, tool: toolManager.currentTool) {
                    settingsTool = nil
                    isShowingColorPicker = false
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .allowsHitTesting(true)
                .zIndex(1)
            }
        }
        .overlay {
            // Dismisses the settings/color-picker popovers on an outside
            // tap. Sits above the canvas (so it can catch taps anywhere on
            // the PDF, not just within the toolbar's own bounds) but below
            // the toolbar overlay below, so the toolbar's own controls still
            // work normally and aren't swallowed by this catcher.
            if isMarkupActive && (settingsTool != nil || isShowingColorPicker) {
                Color.black.opacity(0.0001)
                    .onTapGesture {
                        settingsTool = nil
                        isShowingColorPicker = false
                    }
                    .zIndex(1.5)
            }
        }
        .overlay(alignment: .top) {
            // `PencilToolbar` fills the width it's given and positions its
            // own content horizontally (centered when expanded, docked to
            // an edge when collapsed) — this `.top` alignment only pins it
            // vertically near the top, for both states.
            if isMarkupActive {
                PencilToolbar(
                    toolManager: toolManager,
                    isCollapsed: $isToolbarCollapsed,
                    settingsTool: $settingsTool,
                    isShowingColorPicker: $isShowingColorPicker,
                    collapseSide: $toolbarCollapseSide
                )
                .zIndex(2)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if summary != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingSummary = true
                    } label: {
                        Image(systemName: "doc.text")
                    }
                    .accessibilityLabel("Summary")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isMarkupActive.toggle()
                } label: {
                    Label("Markup", systemImage: isMarkupActive ? "pencil.tip.crop.circle.fill" : "pencil.tip.crop.circle")
                }
            }
        }
        .sheet(isPresented: $isShowingSummary) {
            if let summary {
                SummaryEditorView(summary: summary, onSave: onSummaryEdit)
            }
        }
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
