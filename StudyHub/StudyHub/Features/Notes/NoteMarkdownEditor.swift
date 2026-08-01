import SwiftUI
import UIKit

/// A single formatting action requested by `NoteMarkdownToolbar`, applied to
/// `NoteMarkdownEditor`'s underlying `UITextView` at its current selection.
/// See DECISION-033: formatting is written as Markdown syntax into the
/// existing `Note.body: String`, not as rich-text data — this editor then
/// *displays* that same plain Markdown text with cursor-aware live styling,
/// Obsidian Live Preview-style: whichever line(s) the cursor is NOT on
/// render fully formatted with their Markdown syntax characters concealed;
/// the line(s) the cursor IS on show the raw source so it stays editable.
enum NoteMarkdownFormattingAction: Equatable {
    case heading(level: Int)
    case bold
    case italic
    case bulletList
    case numberedList
    case codeBlock
}

/// Live bridge from `NoteMarkdownToolbar`'s buttons directly to the
/// on-screen `UITextView`/`Coordinator` pair.
///
/// Formatting used to be requested via a `@Binding var pendingAction` that
/// `updateUIView` applied and then cleared with `DispatchQueue.main.async`.
/// Clearing it was asynchronous, but applying it wrote to the `text`
/// binding *synchronously*, which triggered an immediate re-render and a
/// fresh `updateUIView` call before the clear had run — so the same action
/// got applied again, and again, forever. Routing formatting through a
/// plain method call instead means nothing is written to SwiftUI state to
/// be "noticed" and redelivered — each tap applies exactly once.
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
        textView.backgroundColor = .clear
        textView.isScrollEnabled = true
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.delegate = context.coordinator
        textView.attributedText = Coordinator.styledAttributedString(from: text, activeRange: NSRange(location: 0, length: 0))
        textView.typingAttributes = Coordinator.defaultTypingAttributes()
        controller.coordinator = context.coordinator
        controller.textView = textView
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        context.coordinator.syncIfNeeded(text, into: uiView)
        controller.coordinator = context.coordinator
        controller.textView = uiView
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    @MainActor
    final class Coordinator: NSObject, UITextViewDelegate {
        private let text: Binding<String>

        /// Re-entrancy guard for `restyle(_:preserveSelection:)`. Setting
        /// `textView.attributedText` may itself trigger `textViewDidChange`
        /// on some iOS versions — without this guard, that would call
        /// `restyle` again, which sets `.attributedText` again, which could
        /// trigger `textViewDidChange` again, recursing indefinitely. This
        /// is the same class of bug the toolbar's `pendingAction` binding
        /// had; the fix here is the same shape: make re-application
        /// structurally impossible rather than racing a cleanup step
        /// against it.
        private var isApplyingStyling = false

        init(text: Binding<String>) {
            self.text = text
        }

        func textViewDidChange(_ textView: UITextView) {
            text.wrappedValue = textView.text
            restyle(textView, preserveSelection: true)
        }

        /// Fires on every cursor move/tap/selection drag — this is what
        /// makes concealment cursor-aware: moving off a line re-conceals
        /// its Markdown syntax, moving onto a line reveals it.
        func textViewDidChangeSelection(_ textView: UITextView) {
            restyle(textView, preserveSelection: true)
        }

        /// Applies one formatting action at `textView.selectedRange`, writes
        /// the result back through `text`, restyles, and repositions the
        /// cursor. All range math is `NSString`-based since
        /// `UITextView.selectedRange` is UTF-16-based, not
        /// `String.Index`-based.
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
            case .codeBlock:
                wrapAsCodeBlock(to: textView)
            }
            text.wrappedValue = textView.text
            restyle(textView, preserveSelection: true)
        }

        /// Pushes an externally-driven `text` change (e.g. loading an
        /// existing note's body on appear) into the text view.
        func syncIfNeeded(_ newText: String, into textView: UITextView) {
            guard textView.text != newText else { return }
            textView.text = newText
            restyle(textView, preserveSelection: false)
        }

        // MARK: Live styling

        /// Re-derives styling for the entire text view content from its
        /// current plain-text string and current selection. Guarded against
        /// re-entrancy (see `isApplyingStyling`) — both `.attributedText =`
        /// and `.selectedRange =` below can themselves trigger
        /// `textViewDidChange`/`textViewDidChangeSelection` again on some
        /// iOS versions; the guard makes any such reentrant call a no-op
        /// instead of a second application, so there's no path back to an
        /// unbounded loop regardless of which delegate method re-enters.
        private func restyle(_ textView: UITextView, preserveSelection: Bool) {
            guard !isApplyingStyling else { return }
            isApplyingStyling = true
            defer { isApplyingStyling = false }

            let selectedRange = textView.selectedRange
            textView.attributedText = Self.styledAttributedString(from: textView.text, activeRange: selectedRange)
            textView.typingAttributes = Self.defaultTypingAttributes()

            if preserveSelection {
                // Restyling fires on every selection change (including
                // mid-drag while the user is actively selecting text), so
                // this has to restore the *full* range, not just the
                // cursor location — collapsing to length 0 here was
                // erasing the user's selection the instant they started
                // making one, which made "select text, tap Bold" a no-op.
                let textLength = (textView.text as NSString).length
                let clampedLocation = min(selectedRange.location, textLength)
                let clampedLength = min(selectedRange.length, textLength - clampedLocation)
                textView.selectedRange = NSRange(location: clampedLocation, length: clampedLength)
            }
        }

        static func defaultTypingAttributes() -> [NSAttributedString.Key: Any] {
            [.font: UIFont.preferredFont(forTextStyle: .body), .foregroundColor: UIColor.label]
        }

        /// Builds a fully-restyled attributed string from plain Markdown
        /// text and the current cursor/selection (`activeRange`).
        ///
        /// A line is "active" when `activeRange` touches it (the normal
        /// single-cursor case, or every line a multi-line selection spans).
        /// Active lines render as plain, unstyled source text — exactly
        /// what's actually typed, so it's unambiguous to edit. Inactive
        /// lines render fully formatted: heading/emphasis Markdown syntax
        /// (`#`, `**`, `*`) is concealed (shrunk to near-zero size and made
        /// transparent — the characters stay in the real string, so editing,
        /// cursor math, undo, and the saved Note.body are all unaffected;
        /// only their on-screen presence is suppressed). Structural markers
        /// (bullet/numbered markers, code fences) are dimmed rather than
        /// concealed, since unlike `**`/`#` they carry information a fully
        /// rendered line still needs (that this is a list item, which
        /// number).
        /// `activeRange` is `nil` for a pure read-only preview (e.g.
        /// `NoteMarkdownPreview`) — with no cursor at all, no line should
        /// ever be treated as "active"/raw, so every line renders fully
        /// formatted. `NSNotFound` as the sentinel location makes every
        /// real line-range comparison below false without special-casing
        /// the nil branch throughout the rest of this function.
        static func styledAttributedString(from text: String, activeRange: NSRange?) -> NSAttributedString {
            let bodyFont = UIFont.preferredFont(forTextStyle: .body)
            let result = NSMutableAttributedString(
                string: text,
                attributes: [.font: bodyFont, .foregroundColor: UIColor.label]
            )

            let nsText = text as NSString
            let fullRange = NSRange(location: 0, length: nsText.length)
            let activeLineRange: NSRange = activeRange.map { nsText.lineRange(for: $0) } ?? NSRange(location: NSNotFound, length: 0)

            var lineRanges: [NSRange] = []
            nsText.enumerateSubstrings(in: fullRange, options: .byLines) { _, lineRange, _, _ in
                lineRanges.append(lineRange)
            }
            let lines = lineRanges.map { nsText.substring(with: $0) }
            let codeBlockActiveByLine = Self.codeBlockActivity(lines: lines, lineRanges: lineRanges, activeLineRange: activeLineRange)

            var isInsideCodeFence = false
            for index in lines.indices {
                let line = lines[index]
                let lineRange = lineRanges[index]
                let isActiveLine = lineRange.location >= activeLineRange.location
                    && NSMaxRange(lineRange) <= NSMaxRange(activeLineRange)

                if line.hasPrefix("```") {
                    isInsideCodeFence.toggle()
                    if codeBlockActiveByLine[index] {
                        result.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: lineRange)
                    } else {
                        conceal(lineRange, in: result)
                    }
                    continue
                }

                if isInsideCodeFence {
                    // Monospaced font stays on even while this line is
                    // active (helpful while actually typing code), but the
                    // dark background is deliberately reserved for inactive
                    // lines — applying it unconditionally made every code
                    // line look "dark" the instant you clicked into it,
                    // with no visual difference between actively editing
                    // and having moved away. Now it only darkens once
                    // you've left the *whole block*.
                    let codeFont = UIFont.monospacedSystemFont(ofSize: bodyFont.pointSize, weight: .regular)
                    result.addAttribute(.font, value: codeFont, range: lineRange)
                    if !codeBlockActiveByLine[index] {
                        result.addAttribute(.backgroundColor, value: UIColor.secondarySystemFill, range: lineRange)
                    }
                    continue
                }

                guard !isActiveLine else { continue } // plain source, no further styling while editing this line

                if let heading = headingPrefix(of: line) {
                    let headingFont = Self.headingFont(for: heading.level, base: bodyFont)
                    result.addAttribute(.font, value: headingFont, range: lineRange)
                    conceal(NSRange(location: lineRange.location, length: heading.markerLength), in: result)
                } else if line.hasPrefix("- ") || line.hasPrefix("* ") {
                    result.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: NSRange(location: lineRange.location, length: 2))
                } else if let numberedMarkerLength = numberedListMarkerLength(of: line) {
                    result.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: NSRange(location: lineRange.location, length: numberedMarkerLength))
                }

                applyInlineStyling(to: result, inLine: line, lineStart: lineRange.location, bodyFont: bodyFont)
            }

            return result
        }

        /// Pairs up ``` fence lines into blocks and marks every line in a
        /// block "active" if the cursor is anywhere inside that block — not
        /// just on an exact fence line. Inserting a new code block via the
        /// toolbar places the cursor on the empty *content* line between
        /// the two fences, not on either fence itself; checking only the
        /// exact line meant both fence markers went invisible the instant
        /// the block was created, with nothing left on screen to show where
        /// it started or ended. An unterminated trailing fence (opened but
        /// never closed) is treated as extending to the end of the text.
        private static func codeBlockActivity(lines: [String], lineRanges: [NSRange], activeLineRange: NSRange) -> [Bool] {
            var result = [Bool](repeating: false, count: lines.count)
            var blockStart: Int?

            func markBlock(_ start: Int, _ end: Int) {
                let blockRange = NSRange(
                    location: lineRanges[start].location,
                    length: NSMaxRange(lineRanges[end]) - lineRanges[start].location
                )
                let isActive = NSMaxRange(blockRange) >= activeLineRange.location && blockRange.location <= NSMaxRange(activeLineRange)
                for index in start...end { result[index] = isActive }
            }

            for index in lines.indices where lines[index].hasPrefix("```") {
                if let start = blockStart {
                    markBlock(start, index)
                    blockStart = nil
                } else {
                    blockStart = index
                }
            }
            if let start = blockStart {
                markBlock(start, lines.count - 1)
            }

            return result
        }

        /// Shrinks a range to near-zero size and makes it transparent —
        /// visually hides it without removing it from the actual string, so
        /// character offsets/cursor math/undo/the saved text are untouched.
        private static func conceal(_ range: NSRange, in result: NSMutableAttributedString) {
            guard range.length > 0 else { return }
            result.addAttributes([.font: UIFont.systemFont(ofSize: 0.01), .foregroundColor: UIColor.clear], range: range)
        }

        private static func headingPrefix(of line: String) -> (markerLength: Int, level: Int)? {
            if line.hasPrefix("### ") { return (4, 3) }
            if line.hasPrefix("## ") { return (3, 2) }
            if line.hasPrefix("# ") { return (2, 1) }
            return nil
        }

        private static func headingFont(for level: Int, base: UIFont) -> UIFont {
            let style: UIFont.TextStyle = level == 1 ? .title1 : (level == 2 ? .title2 : .title3)
            let font = UIFont.preferredFont(forTextStyle: style)
            let descriptor = font.fontDescriptor.withSymbolicTraits(font.fontDescriptor.symbolicTraits.union(.traitBold)) ?? font.fontDescriptor
            return UIFont(descriptor: descriptor, size: font.pointSize)
        }

        private static func numberedListMarkerLength(of line: String) -> Int? {
            guard let match = line.range(of: #"^\d+\.\s"#, options: .regularExpression) else { return nil }
            return line.distance(from: line.startIndex, to: match.upperBound)
        }

        // Hand-verified, always-valid patterns — safe to force-construct once.
        private static let boldRegex = try! NSRegularExpression(pattern: #"\*\*(.+?)\*\*"#)
        private static let italicRegex = try! NSRegularExpression(pattern: #"(?<!\*)\*([^*]+?)\*(?!\*)"#)

        /// Conceals the `**`/`*` markers themselves and styles just the
        /// enclosed text bold/italic — only called for inactive lines (see
        /// `styledAttributedString`), so this is what makes "**bold**"
        /// visually become "bold" until the cursor moves onto that line.
        private static func applyInlineStyling(to result: NSMutableAttributedString, inLine line: String, lineStart: Int, bodyFont: UIFont) {
            let fullRange = NSRange(location: 0, length: (line as NSString).length)
            let boldFont = boldVariant(of: bodyFont)
            let italicFont = italicVariant(of: bodyFont)

            boldRegex.enumerateMatches(in: line, range: fullRange) { match, _, _ in
                guard let match, match.numberOfRanges > 1 else { return }
                let inner = shifted(match.range(at: 1), by: lineStart)
                concealMarkers(around: inner, markerLength: 2, in: result)
                result.addAttribute(.font, value: boldFont, range: inner)
            }

            italicRegex.enumerateMatches(in: line, range: fullRange) { match, _, _ in
                guard let match, match.numberOfRanges > 1 else { return }
                let inner = shifted(match.range(at: 1), by: lineStart)
                concealMarkers(around: inner, markerLength: 1, in: result)
                result.addAttribute(.font, value: italicFont, range: inner)
            }
        }

        private static func concealMarkers(around inner: NSRange, markerLength: Int, in result: NSMutableAttributedString) {
            conceal(NSRange(location: inner.location - markerLength, length: markerLength), in: result)
            conceal(NSRange(location: inner.location + inner.length, length: markerLength), in: result)
        }

        private static func boldVariant(of font: UIFont) -> UIFont {
            let descriptor = font.fontDescriptor.withSymbolicTraits(font.fontDescriptor.symbolicTraits.union(.traitBold)) ?? font.fontDescriptor
            return UIFont(descriptor: descriptor, size: font.pointSize)
        }

        private static func italicVariant(of font: UIFont) -> UIFont {
            let descriptor = font.fontDescriptor.withSymbolicTraits(font.fontDescriptor.symbolicTraits.union(.traitItalic)) ?? font.fontDescriptor
            return UIFont(descriptor: descriptor, size: font.pointSize)
        }

        private static func shifted(_ range: NSRange, by offset: Int) -> NSRange {
            NSRange(location: range.location + offset, length: range.length)
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

        // MARK: Line-prefix toggles (heading/bulletList)

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
