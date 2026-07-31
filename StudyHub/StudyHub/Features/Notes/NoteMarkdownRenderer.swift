import SwiftUI

/// Read-only rendering of a Note's Markdown body for "Preview" mode.
///
/// Recognizes exactly the block-level syntax `NoteMarkdownEditor`'s
/// formatting toolbar produces (headings, bullet/numbered/checklist items,
/// fenced code blocks) via a small line-based classifier, then renders each
/// line's remaining inline text (bold/italic) through Apple's own
/// `AttributedString(markdown:)` parser. Deliberately not a general
/// CommonMark implementation — scoped to what this app's own editor writes,
/// per DECISION-033.
struct NoteMarkdownRenderer: View {
    let markdown: String
    /// Called with the 0-based source-line index of a tapped checklist item,
    /// so the caller can flip `[ ]`/`[x]` in the underlying text.
    let onToggleChecklist: (Int) -> Void

    var body: some View {
        let blocks = Self.parseBlocks(from: markdown)
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                blockView(block)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func blockView(_ block: Block) -> some View {
        switch block {
        case .heading(let level, let text):
            styledText(text)
                .font(headingFont(for: level))
                .fontWeight(.bold)

        case .bullet(let text):
            HStack(alignment: .top, spacing: 8) {
                Text("•")
                styledText(text)
            }

        case .numbered(let number, let text):
            HStack(alignment: .top, spacing: 8) {
                Text("\(number).")
                styledText(text)
            }

        case .checklist(let lineIndex, let checked, let text):
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: checked ? "checkmark.square.fill" : "square")
                    .foregroundStyle(checked ? Color.accentColor : .secondary)
                styledText(text)
                    .strikethrough(checked)
                    .foregroundStyle(checked ? .secondary : .primary)
            }
            .contentShape(Rectangle())
            .onTapGesture { onToggleChecklist(lineIndex) }

        case .codeBlock(let lines):
            Text(lines.joined(separator: "\n"))
                .font(.system(.body, design: .monospaced))
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))

        case .paragraph(let text):
            styledText(text)

        case .blank:
            Spacer().frame(height: 4)
        }
    }

    private func styledText(_ raw: String) -> Text {
        if let attributed = try? AttributedString(markdown: raw, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)) {
            return Text(attributed)
        }
        return Text(raw)
    }

    private func headingFont(for level: Int) -> Font {
        switch level {
        case 1: return .title
        case 2: return .title2
        default: return .title3
        }
    }

    private enum Block {
        case heading(level: Int, text: String)
        case bullet(text: String)
        case numbered(number: Int, text: String)
        case checklist(lineIndex: Int, checked: Bool, text: String)
        case codeBlock(lines: [String])
        case paragraph(text: String)
        case blank
    }

    private static func parseBlocks(from markdown: String) -> [Block] {
        let lines = markdown.components(separatedBy: "\n")
        var blocks: [Block] = []
        var index = 0
        var numberCounter = 1
        let numberedPattern = #"^\d+\.\s"#

        while index < lines.count {
            let line = lines[index]

            if line.hasPrefix("```") {
                var codeLines: [String] = []
                index += 1
                while index < lines.count, !lines[index].hasPrefix("```") {
                    codeLines.append(lines[index])
                    index += 1
                }
                index += 1 // skip the closing fence (or run past end if unterminated)
                blocks.append(.codeBlock(lines: codeLines))
                numberCounter = 1
                continue
            }

            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                blocks.append(.blank)
                numberCounter = 1
                index += 1
                continue
            }

            if let match = line.range(of: numberedPattern, options: .regularExpression) {
                blocks.append(.numbered(number: numberCounter, text: String(line[match.upperBound...])))
                numberCounter += 1
                index += 1
                continue
            }

            numberCounter = 1

            if line.hasPrefix("### ") {
                blocks.append(.heading(level: 3, text: String(line.dropFirst(4))))
            } else if line.hasPrefix("## ") {
                blocks.append(.heading(level: 2, text: String(line.dropFirst(3))))
            } else if line.hasPrefix("# ") {
                blocks.append(.heading(level: 1, text: String(line.dropFirst(2))))
            } else if line.hasPrefix("- [ ] ") {
                blocks.append(.checklist(lineIndex: index, checked: false, text: String(line.dropFirst(6))))
            } else if line.hasPrefix("- [x] ") || line.hasPrefix("- [X] ") {
                blocks.append(.checklist(lineIndex: index, checked: true, text: String(line.dropFirst(6))))
            } else if line.hasPrefix("- ") || line.hasPrefix("* ") {
                blocks.append(.bullet(text: String(line.dropFirst(2))))
            } else {
                blocks.append(.paragraph(text: line))
            }

            index += 1
        }

        return blocks
    }
}
