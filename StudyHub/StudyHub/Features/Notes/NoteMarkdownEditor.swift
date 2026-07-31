import SwiftUI
import UIKit

/// A single formatting action requested by `NoteMarkdownToolbar`, applied to
/// `NoteMarkdownEditor`'s underlying `UITextView` at its current selection.
/// See DECISION-033: formatting is written as Markdown syntax into the
/// existing `Note.body: String`, not as rich-text data.
enum NoteMarkdownFormattingAction: Equatable {
    case heading(level: Int)
    case bold
    case italic
    case bulletList
    case numberedList
    case checklist
    case codeBlock
}

/// Live bridge from `NoteMarkdownToolbar`'s buttons directly to the
/// on-screen `UITextView`/`Coordinator` pair.
///
/// Formatting used to be requested via a `@Binding var pendingAction`
/// that `updateUIView` applied and then cleared with
/// `DispatchQueue.main.async`. Clearing it was asynchronous, but applying
/// it wrote to the `text` binding *synchronously*, which triggered an
/// immediate re-render and a fresh `updateUIView` call before the clear had
/// run — so the same action got applied again, and again, forever (toggle
/// actions flipped back and forth endlessly; wrap actions re-wrapped the
/// text on every cycle, growing it without bound). Routing formatting
/// through a plain method call instead means nothing is written to SwiftUI
/// state to be "noticed" and redelivered — each tap applies exactly once.
@MainActor
final class NoteMarkdownEditorController {
    fileprivate weak var coordinator: NoteMarkdownEditor.Coordinator?
    fileprivate weak var textView: UITextView?

    func perform(_ action: NoteMarkdownFormattingAction) {
        guard let coordinator, let textView else { return }
        coordinator.apply(action, to: textView)
    }
}

/// TextKit-backed (`UITextView`) editor for a Note's Markdown body.
///
/// SwiftUI's plain `TextEditor(text:)` doesn't expose the current
/// cursor/selection range on this project's iOS 18 deployment target (the
/// richer `TextEditor(text: AttributedString, selection:)` API needs a newer
/// OS) — formatting actions like "wrap the selected text in `**...**`" need
/// that range, so this wraps `UITextView` directly instead, per DECISION-033.
struct NoteMarkdownEditor: UIViewRepresentable {
    @Binding var text: String
    let controller: NoteMarkdownEditorController

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = .preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.backgroundColor = .clear
        textView.isScrollEnabled = true
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.delegate = context.coordinator
        textView.text = text
        controller.coordinator = context.coordinator
        controller.textView = textView
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        controller.coordinator = context.coordinator
        controller.textView = uiView
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    @MainActor
    final class Coordinator: NSObject, UITextViewDelegate {
        private let text: Binding<String>

        init(text: Binding<String>) {
            self.text = text
        }

        func textViewDidChange(_ textView: UITextView) {
            text.wrappedValue = textView.text
        }

        /// Applies one formatting action at `textView.selectedRange`, writes
        /// the result back through `text`, and repositions the cursor. All
        /// range math is `NSString`-based since `UITextView.selectedRange`
        /// is UTF-16-based, not `String.Index`-based.
        func apply(_ action: NoteMarkdownFormattingAction, to textView: UITextView) {
            switch action {
            case .heading(let level):
                let prefix = String(repeating: "#", count: max(1, min(level, 3))) + " "
                applyLinePrefix(prefix, exclusiveWith: ["# ", "## ", "### "], to: textView)
            case .bold:
                wrapSelection(with: "**", to: textView)
            case .italic:
                wrapSelection(with: "*", to: textView)
            case .bulletList:
                applyLinePrefix("- ", exclusiveWith: ["- ", "* "], to: textView)
            case .numberedList:
                applyNumberedList(to: textView)
            case .checklist:
                applyLinePrefix("- [ ] ", exclusiveWith: ["- [ ] ", "- [x] ", "- [X] "], to: textView)
            case .codeBlock:
                wrapAsCodeBlock(to: textView)
            }
            text.wrappedValue = textView.text
        }

        // MARK: Inline wrap (bold/italic)

        private func wrapSelection(with marker: String, to textView: UITextView) {
            let nsText = textView.text as NSString
            let selectedRange = textView.selectedRange
            let selected = selectedRange.length > 0 ? nsText.substring(with: selectedRange) : ""
            let replacement = marker + selected + marker
            textView.text = nsText.replacingCharacters(in: selectedRange, with: replacement)

            let cursor = selectedRange.length > 0
                ? selectedRange.location + (replacement as NSString).length
                : selectedRange.location + (marker as NSString).length
            textView.selectedRange = NSRange(location: cursor, length: 0)
        }

        // MARK: Code block wrap

        private func wrapAsCodeBlock(to textView: UITextView) {
            let nsText = textView.text as NSString
            let selectedRange = textView.selectedRange
            let selected = selectedRange.length > 0 ? nsText.substring(with: selectedRange) : ""
            let replacement = "```\n" + selected + "\n```"
            textView.text = nsText.replacingCharacters(in: selectedRange, with: replacement)
            textView.selectedRange = NSRange(location: selectedRange.location + 4, length: 0) // just after "```\n"
        }

        // MARK: Numbered list (sequential renumbering)

        private func applyNumberedList(to textView: UITextView) {
            let nsText = textView.text as NSString
            let selectedRange = textView.selectedRange
            let lineRange = nsText.lineRange(for: selectedRange)
            let affectedText = nsText.substring(with: lineRange)
            let hadTrailingNewline = affectedText.hasSuffix("\n")
            var lines = affectedText.components(separatedBy: "\n")
            if hadTrailingNewline { lines.removeLast() }

            let numberedPattern = #"^\d+\.\s"#
            let alreadyNumbered = lines.allSatisfy { $0.range(of: numberedPattern, options: .regularExpression) != nil }

            var newLines: [String] = []
            var number = 1
            for line in lines {
                let stripped = line.replacingOccurrences(of: numberedPattern, with: "", options: .regularExpression)
                if alreadyNumbered {
                    newLines.append(stripped)
                } else {
                    newLines.append("\(number). \(stripped)")
                    number += 1
                }
            }

            replaceLines(lineRange: lineRange, newLines: newLines, hadTrailingNewline: hadTrailingNewline, in: textView)
        }

        // MARK: Line-prefix toggles (heading/bulletList/checklist)

        /// Toggles `prefix` at the start of every line touched by the
        /// current selection, line by line. A line already starting with
        /// `prefix` has it stripped (toggle off); a line starting with a
        /// different marker in `exclusiveWith` has that marker replaced
        /// (e.g. switching heading level, or Heading -> Bullet); otherwise
        /// `prefix` is simply prepended.
        private func applyLinePrefix(_ prefix: String, exclusiveWith: [String], to textView: UITextView) {
            let nsText = textView.text as NSString
            let selectedRange = textView.selectedRange
            let lineRange = nsText.lineRange(for: selectedRange)
            let affectedText = nsText.substring(with: lineRange)
            let hadTrailingNewline = affectedText.hasSuffix("\n")
            var lines = affectedText.components(separatedBy: "\n")
            if hadTrailingNewline { lines.removeLast() }

            let newLines = lines.map { line -> String in
                if line.hasPrefix(prefix) {
                    return String(line.dropFirst(prefix.count))
                }
                for marker in exclusiveWith where line.hasPrefix(marker) {
                    return prefix + String(line.dropFirst(marker.count))
                }
                return prefix + line
            }

            replaceLines(lineRange: lineRange, newLines: newLines, hadTrailingNewline: hadTrailingNewline, in: textView)
        }

        private func replaceLines(lineRange: NSRange, newLines: [String], hadTrailingNewline: Bool, in textView: UITextView) {
            let replacement = newLines.joined(separator: "\n") + (hadTrailingNewline ? "\n" : "")
            let nsText = textView.text as NSString
            textView.text = nsText.replacingCharacters(in: lineRange, with: replacement)
            textView.selectedRange = NSRange(location: lineRange.location + (replacement as NSString).length, length: 0)
        }
    }
}

/// Formatting toolbar for `NoteMarkdownEditor` — each button calls
/// `controller.perform(_:)` directly, applying the action to the live text
/// view immediately rather than routing it through SwiftUI state.
struct NoteMarkdownToolbar: View {
    let controller: NoteMarkdownEditorController

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                Menu {
                    Button("Title") { controller.perform(.heading(level: 1)) }
                    Button("Heading") { controller.perform(.heading(level: 2)) }
                    Button("Subheading") { controller.perform(.heading(level: 3)) }
                } label: {
                    Image(systemName: "textformat.size")
                }

                button("bold", action: .bold, label: "Bold")
                button("italic", action: .italic, label: "Italic")
                button("list.bullet", action: .bulletList, label: "Bullet List")
                button("list.number", action: .numberedList, label: "Numbered List")
                button("checklist", action: .checklist, label: "Checklist")
                button("curlybraces", action: .codeBlock, label: "Code Block")
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }

    private func button(_ systemImage: String, action: NoteMarkdownFormattingAction, label: String) -> some View {
        Button {
            controller.perform(action)
        } label: {
            Image(systemName: systemImage)
        }
        .accessibilityLabel(label)
    }
}
