import PDFKit
import PencilKit
import SwiftUI

/// Reusable, owner-agnostic PDF viewer. Displays a PDF from any plain URL string
/// (an `Attachment.url` or a `Resource.url`) using native `PDFKit` behavior only —
/// scrolling, pinch-to-zoom, text selection, copy, and page rendering are all
/// inherited from `PDFView` for free.
///
/// Also hosts the Markup mode toolbar (Phase 3N.6.1A) and persisted PencilKit
/// markup (Phase 3N.6.4): a Summary button (shown only when the caller passes
/// non-nil `summary` text) and a Markup toggle that overlays per-page
/// `PKCanvasView`s (via `PDFMarkupCoordinator`) on top of the PDF. Existing
/// markup is restored automatically when the PDF loads; new/changed markup is
/// saved automatically when Markup mode is closed, via `onMarkupSave` — this
/// view has no repository access itself, so persistence is always the
/// caller's responsibility (mirrors `onSummaryEdit`).
struct PDFViewerView: View {
    let title: String
    let sourceURL: String
    let summary: String?
    let onSummaryEdit: ((String) -> Void)?
    let initialMarkupData: Data?
    let onMarkupSave: ((Data) -> Void)?
    let pdfService: any PDFServiceProtocol

    @State private var viewModel: PDFViewerViewModel

    @State private var isMarkupActive = false
    @State private var isShowingSummary = false
    @State private var toolManager = PencilToolManager()
    @State private var isToolbarCollapsed = false
    @State private var settingsTool: PencilToolKind?
    @State private var isShowingColorPicker = false
    @State private var toolbarCollapseSide: ToolbarCollapseSide = .right
    @State private var markupCoordinator = PDFMarkupCoordinator()

    init(
        title: String,
        sourceURL: String,
        summary: String? = nil,
        onSummaryEdit: ((String) -> Void)? = nil,
        initialMarkupData: Data? = nil,
        onMarkupSave: ((Data) -> Void)? = nil,
        pdfService: any PDFServiceProtocol
    ) {
        self.title = title
        self.sourceURL = sourceURL
        self.summary = summary
        self.onSummaryEdit = onSummaryEdit
        self.initialMarkupData = initialMarkupData
        self.onMarkupSave = onMarkupSave
        self.pdfService = pdfService
        _viewModel = State(wrappedValue: PDFViewerViewModel(sourceURL: sourceURL, pdfService: pdfService))
    }

    init(
        attachment: Attachment,
        summary: String? = nil,
        onSummaryEdit: ((String) -> Void)? = nil,
        onMarkupSave: ((Data) -> Void)? = nil,
        pdfService: any PDFServiceProtocol
    ) {
        self.init(
            title: attachment.filename,
            sourceURL: attachment.url,
            summary: summary,
            onSummaryEdit: onSummaryEdit,
            initialMarkupData: attachment.markupData,
            onMarkupSave: onMarkupSave,
            pdfService: pdfService
        )
    }

    var body: some View {
        Group {
            if let document = viewModel.document {
                PDFKitRepresentedView(
                    document: document,
                    markupCoordinator: markupCoordinator,
                    toolManager: toolManager,
                    isMarkupActive: isMarkupActive
                )
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
            // Dismisses the settings/color-picker popovers on an outside
            // tap. The per-page markup canvases now live inside PDFView's
            // own hierarchy (via PDFPageOverlayViewProvider), not as a
            // sibling SwiftUI overlay, so this only needs to sit above the
            // PDF and below the toolbar.
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
            markupCoordinator.configure(toolManager: toolManager) {
                settingsTool = nil
                isShowingColorPicker = false
            }
            if viewModel.document != nil {
                markupCoordinator.loadStoredMarkup(initialMarkupData, document: viewModel.document)
            }
        }
        .onChange(of: viewModel.document == nil) { _, isNil in
            if !isNil {
                markupCoordinator.loadStoredMarkup(initialMarkupData, document: viewModel.document)
            }
        }
        .onChange(of: isMarkupActive) { wasActive, isActive in
            // Clears any active lasso selection on every Markup on/off
            // transition, so a selection never silently survives leaving
            // Markup mode (and re-entering always starts unselected).
            markupCoordinator.clearActiveSelections()
            if wasActive && !isActive, let data = markupCoordinator.exportMarkupData() {
                onMarkupSave?(data)
            }
        }
    }
}

/// Thin `UIViewRepresentable` wrapper around `PDFKit.PDFView`. Configures
/// auto-scaling and continuous vertical paging only — everything else (text
/// selection, copy, native search via `PDFDocument.findString`, page rendering)
/// is `PDFView`'s own default behavior and is left untouched. Also wires in
/// `PDFMarkupCoordinator` as the page overlay provider and toggles
/// `isInMarkupMode` (Phase 3N.6.4) — while Markup is active, gestures route
/// to the per-page canvases instead of PDFView's own scroll/zoom/select.
private struct PDFKitRepresentedView: UIViewRepresentable {
    let document: PDFDocument
    let markupCoordinator: PDFMarkupCoordinator
    let toolManager: PencilToolManager
    let isMarkupActive: Bool

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        // `pageOverlayViewProvider` must be set BEFORE `document` — PDFKit's
        // header states `layoutDocumentView()` runs automatically as soon as
        // `document` is assigned, and that's the pass that calls
        // `overlayViewForPage:` for every page. Assigning the provider after
        // `document` means that first, automatic pass sees a nil provider
        // and never asks for an overlay at all.
        pdfView.pageOverlayViewProvider = markupCoordinator
        pdfView.document = document
        pdfView.isInMarkupMode = isMarkupActive
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        if uiView.document !== document {
            uiView.document = document
        }
        uiView.isInMarkupMode = isMarkupActive
        // `isInMarkupMode` toggling alone doesn't retrigger PDFKit's layout
        // pass — `layoutDocumentView()` is documented as automatic only on
        // `setDocument`/`setDisplayBox`. Forcing it here is what actually
        // makes PDFKit re-ask the provider for overlays on already-laid-out
        // pages once Markup mode turns on.
        uiView.layoutDocumentView()
        markupCoordinator.refreshTool()
    }
}
