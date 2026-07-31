import SwiftUI

/// Presentational find-in-PDF bar — text field, match counter, prev/next,
/// close. Holds no search logic itself; `PDFViewerView` owns the query
/// text and wires this to `PDFViewerViewModel`'s search methods, mirroring
/// how `PencilToolbar` stays UI-only and defers to `PencilToolManager`.
struct PDFFindBar: View {
    @Binding var query: String
    let matchCountText: String?
    let hasMatches: Bool
    /// True while a search (including the Find-open index prewarm) is
    /// running in the background — shown as a spinner in place of the
    /// magnifying glass so a slow first search on a large PDF reads as
    /// "working" instead of a silent freeze.
    let isSearching: Bool
    let onSearch: () -> Void
    let onNext: () -> Void
    let onPrevious: () -> Void
    let onClose: () -> Void

    @FocusState private var isFieldFocused: Bool

    var body: some View {
        HStack(spacing: 8) {
            if isSearching {
                ProgressView()
                    .controlSize(.small)
            } else {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
            }

            TextField("Find in PDF", text: $query)
                .textFieldStyle(.plain)
                .focused($isFieldFocused)
                .onSubmit(onSearch)
                // Debounced — `PDFDocument.findString` is a synchronous,
                // main-actor, full-document search; running it on every
                // keystroke blocked the main thread long enough on larger
                // PDFs to make the keyboard itself feel laggy while typing.
                // `task(id:)` cancels the previous wait whenever `query`
                // changes, so only a settled value actually triggers a
                // search. Safe to debounce now (this was deliberately
                // synchronous-per-keystroke before): correctness no longer
                // depends on this timing, `PDFViewerViewModel.searchStateVersion`
                // is what actually gates the highlight refresh, regardless
                // of how long each search takes to run. Clearing the field
                // still searches (clears results) immediately, no delay.
                .task(id: query) {
                    guard !query.isEmpty else {
                        onSearch()
                        return
                    }
                    try? await Task.sleep(for: .milliseconds(200))
                    guard !Task.isCancelled else { return }
                    onSearch()
                }

            if let matchCountText {
                Text(matchCountText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .fixedSize()
            }

            Button(action: onPrevious) {
                Image(systemName: "chevron.up")
            }
            .disabled(!hasMatches)

            Button(action: onNext) {
                Image(systemName: "chevron.down")
            }
            .disabled(!hasMatches)

            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.regularMaterial, in: Capsule())
        .padding(.horizontal)
        .padding(.top, 8)
        .onAppear {
            isFieldFocused = true
        }
    }
}
