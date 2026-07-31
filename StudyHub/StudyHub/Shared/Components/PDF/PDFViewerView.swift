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
    let bookmarkRepository: any BookmarkRepositoryProtocol
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
    @State private var navigationCoordinator = PDFNavigationCoordinator()
    @State private var isFindActive = false
    @State private var findQuery = ""
    @State private var isShowingBookmarks = false
    @State private var isShowingOutline = false

    init(
        title: String,
        sourceURL: String,
        summary: String? = nil,
        onSummaryEdit: ((String) -> Void)? = nil,
        initialMarkupData: Data? = nil,
        onMarkupSave: ((Data) -> Void)? = nil,
        bookmarkRepository: any BookmarkRepositoryProtocol,
        pdfService: any PDFServiceProtocol
    ) {
        self.title = title
        self.sourceURL = sourceURL
        self.summary = summary
        self.onSummaryEdit = onSummaryEdit
        self.initialMarkupData = initialMarkupData
        self.onMarkupSave = onMarkupSave
        self.bookmarkRepository = bookmarkRepository
        self.pdfService = pdfService
        _viewModel = State(wrappedValue: PDFViewerViewModel(
            sourceURL: sourceURL,
            pdfService: pdfService,
            bookmarkRepository: bookmarkRepository
        ))
    }

    init(
        attachment: Attachment,
        summary: String? = nil,
        onSummaryEdit: ((String) -> Void)? = nil,
        onMarkupSave: ((Data) -> Void)? = nil,
        bookmarkRepository: any BookmarkRepositoryProtocol,
        pdfService: any PDFServiceProtocol
    ) {
        self.init(
            title: attachment.filename,
            sourceURL: attachment.url,
            summary: summary,
            onSummaryEdit: onSummaryEdit,
            initialMarkupData: attachment.markupData,
            onMarkupSave: onMarkupSave,
            bookmarkRepository: bookmarkRepository,
            pdfService: pdfService
        )
    }

    var body: some View {
        Group {
            if let document = viewModel.document {
                PDFKitRepresentedView(
                    document: document,
                    markupCoordinator: markupCoordinator,
                    navigationCoordinator: navigationCoordinator,
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
        .overlay(alignment: .top) {
            if isFindActive {
                PDFFindBar(
                    query: $findQuery,
                    matchCountText: findMatchCountText,
                    hasMatches: !viewModel.searchMatches.isEmpty,
                    onSearch: { viewModel.search(for: findQuery) },
                    onNext: { viewModel.goToNextMatch() },
                    onPrevious: { viewModel.goToPreviousMatch() },
                    onClose: { isFindActive = false }
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
                    isFindActive.toggle()
                } label: {
                    Image(systemName: "magnifyingglass")
                }
                .accessibilityLabel("Find in PDF")
            }
            ToolbarItem(placement: .topBarTrailing) {
                bookmarkToggleButton
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingBookmarks = true
                } label: {
                    Image(systemName: "list.bullet")
                }
                .accessibilityLabel("View Bookmarks")
            }
            // Hidden entirely (not just disabled) when the PDF has no
            // outline — nothing to show, so no icon to tap.
            if viewModel.hasOutline {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingOutline = true
                    } label: {
                        Label("Contents", systemImage: "text.book.closed")
                    }
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
        .sheet(isPresented: $isShowingBookmarks) {
            PDFBookmarkListView(
                pdfTitle: title,
                bookmarks: viewModel.bookmarks,
                onSelect: { bookmark in
                    navigationCoordinator.goToPage(index: bookmark.pageIndex)
                    isShowingBookmarks = false
                },
                onDelete: { bookmark in
                    viewModel.deleteBookmark(bookmark)
                }
            )
        }
        .sheet(isPresented: $isShowingOutline) {
            PDFOutlineListView(outline: viewModel.outline) { node in
                if let destination = node.destination {
                    navigationCoordinator.goToDestination(destination)
                }
                isShowingOutline = false
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
            viewModel.loadBookmarks()
            viewModel.loadOutline()
        }
        .onChange(of: viewModel.document == nil) { _, isNil in
            if !isNil {
                markupCoordinator.loadStoredMarkup(initialMarkupData, document: viewModel.document)
                viewModel.loadOutline()
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
        .onChange(of: viewModel.searchStateVersion) { _, _ in
            navigationCoordinator.showSearchMatches(
                viewModel.searchMatches.map(\.selection),
                currentIndex: viewModel.currentMatchIndex
            )
        }
        .onChange(of: isFindActive) { _, isActive in
            if !isActive {
                findQuery = ""
                viewModel.clearSearch()
                navigationCoordinator.clearSearchMatches()
            }
        }
    }

    private var findMatchCountText: String? {
        guard !findQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        guard !viewModel.searchMatches.isEmpty else { return "No results" }
        return "\((viewModel.currentMatchIndex ?? 0) + 1) of \(viewModel.searchMatches.count)"
    }

    /// Toggles a bookmark on whichever page is currently on screen — a plain
    /// tap, not a menu, per the "tapping creates/removes" requirement.
    /// `navigationCoordinator.currentPageIndex` is `@Observable`-backed now,
    /// so this button's filled/outline state actually updates as the user
    /// scrolls, instead of only refreshing on unrelated re-renders.
    private var bookmarkToggleButton: some View {
        let currentPageIndex = navigationCoordinator.currentPageIndex
        let isCurrentPageBookmarked = currentPageIndex.map(viewModel.isBookmarked) ?? false

        return Button {
            guard let currentPageIndex else { return }
            viewModel.toggleBookmark(pageIndex: currentPageIndex)
        } label: {
            Image(systemName: isCurrentPageBookmarked ? "bookmark.fill" : "bookmark")
        }
        .disabled(currentPageIndex == nil)
        .accessibilityLabel(isCurrentPageBookmarked ? "Remove Bookmark" : "Bookmark This Page")
    }
}

/// Lists every bookmark for this PDF — tap to jump to that page, swipe to
/// delete. A plain sheet (matches `SummaryEditorView`'s simplicity) rather
/// than a new persistence-aware view: it only reads `bookmarks` and forwards
/// taps to closures `PDFViewerView` already has the view model for.
private struct PDFBookmarkListView: View {
    let pdfTitle: String
    let bookmarks: [Bookmark]
    let onSelect: (Bookmark) -> Void
    let onDelete: (Bookmark) -> Void

    @Environment(\.dismiss) private var dismiss

    private var sortedBookmarks: [Bookmark] {
        bookmarks.sorted { $0.pageIndex < $1.pageIndex }
    }

    var body: some View {
        NavigationStack {
            Group {
                if bookmarks.isEmpty {
                    StudyHubEmptyState(
                        icon: "bookmark",
                        title: "No Bookmarks Yet",
                        message: "Bookmark a page in \(pdfTitle) to find it again quickly."
                    )
                } else {
                    List {
                        ForEach(sortedBookmarks, id: \.id) { bookmark in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(pdfTitle)
                                        .font(.subheadline)
                                    Text(bookmark.pageLabel.map { "Page \($0)" } ?? "Page \(bookmark.pageIndex + 1)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                onSelect(bookmark)
                            }
                            .accessibilityAddTraits(.isButton)
                            .swipeActions(edge: .trailing) {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    onDelete(bookmark)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Bookmarks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

/// Table of contents — a flattened, indented list of every `PDFOutlineNode`
/// (chapters, sections, subsections), preserving hierarchy visually through
/// leading padding proportional to `level` rather than nested
/// `DisclosureGroup`s. Entries with no destination (outline items that carry
/// only a `PDFAction`, which this doesn't handle) are shown but not tappable.
private struct PDFOutlineListView: View {
    let outline: [PDFOutlineNode]
    let onSelect: (PDFOutlineNode) -> Void

    @Environment(\.dismiss) private var dismiss

    private var flattenedOutline: [PDFOutlineNode] {
        Self.flatten(outline)
    }

    private static func flatten(_ nodes: [PDFOutlineNode]) -> [PDFOutlineNode] {
        nodes.flatMap { [$0] + flatten($0.children) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if outline.isEmpty {
                    StudyHubEmptyState(
                        icon: "text.book.closed",
                        title: "No Contents Available",
                        message: "This PDF doesn't include a table of contents."
                    )
                } else {
                    List {
                        ForEach(flattenedOutline, id: \.id) { node in
                            let isNavigable = node.destination != nil

                            Text(node.title)
                                .lineLimit(2)
                                .foregroundStyle(isNavigable ? Color.primary : Color.secondary)
                                .padding(.leading, CGFloat(node.level) * 16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    guard isNavigable else { return }
                                    onSelect(node)
                                }
                                .accessibilityAddTraits(isNavigable ? .isButton : [])
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Contents")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
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
    let navigationCoordinator: PDFNavigationCoordinator
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
        navigationCoordinator.attach(pdfView)
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
