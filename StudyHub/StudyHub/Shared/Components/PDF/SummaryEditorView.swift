import SwiftUI

/// View + edit UI for a PDF's associated summary text (a Note's body, a
/// Reading's notes, a Resource's notes). Self-contained so `PDFViewerView`
/// stays a thin host — it only wires in the current text and an optional
/// save callback; all view/edit-mode state lives here.
struct SummaryEditorView: View {
    let summary: String
    let onSave: ((String) -> Void)?

    @Environment(\.dismiss) private var dismiss
    @State private var displayedText: String
    @State private var draftText: String = ""
    @State private var isEditing = false

    init(summary: String, onSave: ((String) -> Void)?) {
        self.summary = summary
        self.onSave = onSave
        _displayedText = State(initialValue: summary)
    }

    var body: some View {
        NavigationStack {
            Group {
                if isEditing {
                    TextEditor(text: $draftText)
                        .padding(4)
                } else {
                    ScrollView {
                        Text(displayedText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                    }
                }
            }
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if isEditing {
                    if #available(iOS 26.0, *) {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isEditing = false
                            }
                            .summaryToolbarCapsule(prominent: false)
                        }
                        .sharedBackgroundVisibility(.hidden)
                        ToolbarSpacer(.fixed, placement: .confirmationAction)
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                displayedText = draftText
                                onSave?(draftText)
                                isEditing = false
                            }
                            .summaryToolbarCapsule(prominent: true)
                        }
                        .sharedBackgroundVisibility(.hidden)
                    } else {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isEditing = false
                            }
                            .summaryToolbarCapsule(prominent: false)
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                displayedText = draftText
                                onSave?(draftText)
                                isEditing = false
                            }
                            .summaryToolbarCapsule(prominent: true)
                        }
                    }
                } else {
                    if #available(iOS 26.0, *) {
                        if onSave != nil {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Edit") {
                                    draftText = displayedText
                                    isEditing = true
                                }
                                .summaryToolbarCapsule(prominent: false)
                            }
                            .sharedBackgroundVisibility(.hidden)
                            ToolbarSpacer(.fixed, placement: .topBarTrailing)
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                dismiss()
                            }
                            .summaryToolbarCapsule(prominent: true)
                        }
                        .sharedBackgroundVisibility(.hidden)
                    } else {
                        if onSave != nil {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Edit") {
                                    draftText = displayedText
                                    isEditing = true
                                }
                                .summaryToolbarCapsule(prominent: false)
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                dismiss()
                            }
                            .summaryToolbarCapsule(prominent: true)
                        }
                    }
                }
            }
        }
    }
}

private extension View {
    /// System toolbars (both the iOS 26 "glass" style and macOS/Catalyst
    /// chrome, which strips `.buttonStyle(.borderedProminent)` from toolbar
    /// items entirely) don't reliably render a visible pill around a plain
    /// toolbar `Button` on their own — `sharedBackgroundVisibility`/
    /// `ToolbarSpacer` above only stop two buttons from being *merged*
    /// together, they don't add a background to either one. This explicit
    /// capsule guarantees each button is individually visible as its own
    /// button, on every platform this toolbar can render on.
    func summaryToolbarCapsule(prominent: Bool) -> some View {
        self
            .font(.subheadline.weight(prominent ? .regular : .regular))
            .lineLimit(1)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .frame(minWidth: 52)
            .fixedSize()
            .background(
                prominent ? Color.accentColor : Color.secondary.opacity(0.18),
                in: Capsule()
            )
            .foregroundStyle(prominent ? Color.white : Color.primary)
    }
}
