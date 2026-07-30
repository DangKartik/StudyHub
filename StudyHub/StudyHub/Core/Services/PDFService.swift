import Foundation
import PDFKit

protocol PDFServiceProtocol {
    func loadDocument(from urlString: String) throws -> PDFDocument
}

@MainActor
final class PDFService: PDFServiceProtocol {
    func loadDocument(from urlString: String) throws -> PDFDocument {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw PDFError.invalidURL
        }

        let resolvedURL: URL
        if let url = URL(string: trimmed), url.scheme != nil {
            resolvedURL = url
        } else {
            resolvedURL = URL(fileURLWithPath: trimmed)
        }

        guard let document = PDFDocument(url: resolvedURL) else {
            throw PDFError.documentLoadFailed
        }

        return document
    }
}
