import Foundation

extension URL {
    /// Resolves free-text "URL or reference" input (Resources/Attachments'
    /// Link fields) into something safe to hand to `openURL`. A bare domain
    /// typed without "https://" (e.g. "example.com") is the common case for
    /// these fields and should still open — `URL(string:)` alone parses that
    /// successfully but with no `scheme`, which `openURL` then rejects
    /// outright (this was the exact failure logged when a raw local file
    /// path like "/…/pore.pdf" reached `openURL` with no scheme at all —
    /// see the removal of the GoodNotes/Document/Other attachment types).
    /// Distinguishing the two: an absolute path always starts with "/",
    /// which no real web address does, so that's rejected instead of
    /// getting an "https://" prefix slapped onto it.
    static func openable(from string: String) -> URL? {
        guard let url = URL(string: string), !string.isEmpty else { return nil }
        if url.scheme != nil {
            return url
        }
        guard !string.hasPrefix("/") else { return nil }
        return URL(string: "https://\(string)")
    }
}
