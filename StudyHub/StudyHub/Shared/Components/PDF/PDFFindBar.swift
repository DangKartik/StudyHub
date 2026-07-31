import SwiftUI

/// Presentational find-in-PDF bar — text field, match counter, prev/next,
/// close. Holds no search logic itself; `PDFViewerView` owns the query
/// text and wires this to `PDFViewerViewModel`'s search methods, mirroring
/// how `PencilToolbar` stays UI-only and defers to `PencilToolManager`.
struct PDFFindBar: View {
    @Binding var query: String
    let matchCountText: String?
    let hasMatches: Bool
    let onSearch: () -> Void
    let onNext: () -> Void
    let onPrevious: () -> Void
    let onClose: () -> Void

    @FocusState private var isFieldFocused: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Find in PDF", text: $query)
                .textFieldStyle(.plain)
                .focused($isFieldFocused)
                .onSubmit(onSearch)
                // Searches on every keystroke, synchronously — no debounce
                // Task in flight means there's nothing that can race or leave
                // a stale result on screen. `PDFDocument.findString` runs to
                // completion on the main actor before the next keystroke's
                // call can start, so query changes are always reflected
                // immediately and in order.
                .onChange(of: query) { _, _ in onSearch() }

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
