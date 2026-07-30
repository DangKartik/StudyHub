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
    let pdfService: any PDFServiceProtocol

    @State private var viewModel: PDFViewerViewModel

    @State private var isMarkupActive = false
    @State private var isShowingSummary = false
    @State private var canvasController = PencilCanvasController()
    @State private var selectedTool: PencilToolKind = .pencil
    @State private var selectedColor: Color = .blue
    @State private var thickness: CGFloat = 4
    @State private var opacity: Double = 1.0
    @State private var isToolbarCollapsed = false
    @State private var settingsTool: PencilToolKind?
    @State private var isShowingColorPicker = false
    @State private var toolbarCollapseSide: ToolbarCollapseSide = .right

    private var currentTool: PKTool {
        selectedTool.makePKTool(color: selectedColor, thickness: thickness, opacity: opacity)
    }

    init(title: String, sourceURL: String, summary: String? = nil, pdfService: any PDFServiceProtocol) {
        self.title = title
        self.sourceURL = sourceURL
        self.summary = summary
        self.pdfService = pdfService
        _viewModel = State(wrappedValue: PDFViewerViewModel(sourceURL: sourceURL, pdfService: pdfService))
    }

    init(attachment: Attachment, summary: String? = nil, pdfService: any PDFServiceProtocol) {
        self.init(title: attachment.filename, sourceURL: attachment.url, summary: summary, pdfService: pdfService)
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
                PencilCanvasView(controller: canvasController, tool: currentTool) {
                    settingsTool = nil
                    isShowingColorPicker = false
                }
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
            }
        }
        .overlay(alignment: .top) {
            // `PencilToolbar` fills the width it's given and positions its
            // own content horizontally (centered when expanded, docked to
            // an edge when collapsed) — this `.top` alignment only pins it
            // vertically near the top, for both states.
            if isMarkupActive {
                PencilToolbar(
                    selectedTool: $selectedTool,
                    selectedColor: $selectedColor,
                    thickness: $thickness,
                    opacity: $opacity,
                    isCollapsed: $isToolbarCollapsed,
                    settingsTool: $settingsTool,
                    isShowingColorPicker: $isShowingColorPicker,
                    collapseSide: $toolbarCollapseSide,
                    controller: canvasController
                )
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
            summarySheet
        }
        .onAppear {
            if viewModel.document == nil && viewModel.loadError == nil {
                viewModel.loadDocument()
            }
        }
    }

    @ViewBuilder
    private var summarySheet: some View {
        if let summary {
            NavigationStack {
                ScrollView {
                    Text(summary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                .navigationTitle("Summary")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            isShowingSummary = false
                        }
                    }
                }
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
