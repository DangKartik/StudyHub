import Foundation
import PDFKit

@MainActor
@Observable
final class PDFViewerViewModel {
    private let sourceURL: String
    private let pdfService: any PDFServiceProtocol

    private(set) var document: PDFDocument?
    private(set) var loadError: StudyHubError?

    init(sourceURL: String, pdfService: any PDFServiceProtocol) {
        self.sourceURL = sourceURL
        self.pdfService = pdfService
    }

    func loadDocument() {
        do {
            document = try pdfService.loadDocument(from: sourceURL)
            loadError = nil
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PDFError.documentLoadFailed
        }
    }
}
