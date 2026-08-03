import SwiftUI
import UIKit

/// Full-screen, read-only preview of a Note — title, tags, and rendered
/// Markdown body. Every edit (title, tags, body, attachments) happens in one
/// place: `NoteBodyEditorView`, full-screen, reachable from "Edit" — there's
/// no inline editing here anymore. The note's existing attachment(s) stay
/// reachable via explicit "View PDF"/"Open Link" buttons.
struct NoteDetailView: View {
    let note: Note
    let viewModel: NotesViewModel
    let bookmarkRepository: any BookmarkRepositoryProtocol
    let pdfProgressRepository: any PDFProgressRepositoryProtocol
    let pdfService: any PDFServiceProtocol

    @State private var showingBodyEditor = false
    @State private var attachmentForViewing: Attachment?
    @State private var imageForViewing: Attachment?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    /// Every openable attachment (PDF/Image/Link) — a note can carry more
    /// than one, so this shows a button per attachment rather than only
    /// the first.
    private var openableAttachments: [Attachment] {
        note.attachments.filter {
            let kind = AttachmentKind(rawValue: $0.type)
            return kind == .pdf || kind == .image || kind == .link
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header

                    if !note.tags.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(note.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .foregroundStyle(Color.accentColor)
                                    .background(Color.accentColor.opacity(0.15), in: Capsule())
                            }
                        }
                    }

                    if !openableAttachments.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(openableAttachments, id: \.id) { attachment in
                                Button {
                                    openAttachment(attachment)
                                } label: {
                                    Label(attachmentButtonLabel(for: attachment), systemImage: attachmentButtonIcon(for: attachment))
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }

                    Divider()

                    if note.body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text("No additional text")
                            .foregroundStyle(.secondary)
                    } else {
                        NoteMarkdownPreview(text: note.body)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit") { showingBodyEditor = true }
                }
            }
            .fullScreenCover(isPresented: $showingBodyEditor) {
                NoteBodyEditorView(note: note, viewModel: viewModel)
            }
            .fullScreenCover(isPresented: Binding(
                get: { attachmentForViewing != nil },
                set: { isPresented in
                    if !isPresented { attachmentForViewing = nil }
                }
            )) {
                if let attachmentForViewing {
                    let noteBody = note.body.trimmingCharacters(in: .whitespacesAndNewlines)
                    NavigationStack {
                        PDFViewerView(
                            attachment: attachmentForViewing,
                            summary: noteBody.isEmpty ? nil : noteBody,
                            onSummaryEdit: { newBody in
                                viewModel.updateNote(note, title: note.title, body: newBody)
                            },
                            onMarkupSave: { data in
                                viewModel.saveMarkup(data, for: attachmentForViewing)
                            },
                            bookmarkRepository: bookmarkRepository,
                            pdfProgressRepository: pdfProgressRepository,
                            pdfService: pdfService
                        )
                    }
                }
            }
            .fullScreenCover(isPresented: Binding(
                get: { imageForViewing != nil },
                set: { isPresented in
                    if !isPresented { imageForViewing = nil }
                }
            )) {
                if let imageForViewing {
                    NavigationStack {
                        ImageViewerView(attachment: imageForViewing)
                    }
                }
            }
        }
    }

    /// Title, the owner it's attached to (if any), then exactly one date
    /// line: "Edited <date>" once it's actually been edited, else
    /// "Created <date>" — never both, never neither.
    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(note.title.isEmpty ? "Untitled Note" : note.title)
                .font(.title2)
                .fontWeight(.bold)

            if note.hasOwner {
                Text(note.ownerContextLabel)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if note.hasBeenEdited {
                Text("Edited \(note.updatedAt.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("Created \(note.createdAt.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func openAttachment(_ attachment: Attachment) {
        switch AttachmentKind(rawValue: attachment.type) {
        case .pdf:
            attachmentForViewing = attachment
        case .image:
            imageForViewing = attachment
        case .link:
            if let url = URL.openable(from: attachment.url) {
                openURL(url)
            }
        case .none:
            break
        }
    }

    /// Prefixes the attachment's own filename so multiple attachments of
    /// the same kind (e.g. two PDFs) read as distinct buttons rather than
    /// several identical "View PDF" labels.
    private func attachmentButtonLabel(for attachment: Attachment) -> String {
        let kindLabel: String
        switch AttachmentKind(rawValue: attachment.type) {
        case .pdf: kindLabel = "View PDF"
        case .image: kindLabel = "View Image"
        case .link, .none: kindLabel = "Open Link"
        }
        let filename = attachment.filename.trimmingCharacters(in: .whitespacesAndNewlines)
        return filename.isEmpty ? kindLabel : "\(kindLabel): \(filename)"
    }

    private func attachmentButtonIcon(for attachment: Attachment) -> String {
        AttachmentKind(rawValue: attachment.type)?.icon ?? "link"
    }
}

/// Read-only rendering of a Note's Markdown body — reuses
/// `NoteMarkdownEditor`'s exact same styling logic (headings, bold/italic,
/// lists, code blocks) with `activeRange: nil`, so every line renders fully
/// formatted instead of only the lines the cursor isn't on. A `UILabel`
/// rather than a `UITextView` here since this never needs to be edited or
/// scrolled independently — it just sizes itself into the surrounding
/// `ScrollView` like any other read-only text.
private struct NoteMarkdownPreview: UIViewRepresentable {
    let text: String

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.attributedText = NoteMarkdownEditor.Coordinator.styledAttributedString(from: text, activeRange: nil)
        return label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.attributedText = NoteMarkdownEditor.Coordinator.styledAttributedString(from: text, activeRange: nil)
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UILabel, context: Context) -> CGSize? {
        let width = proposal.width ?? UIScreen.main.bounds.width
        return uiView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
    }
}
