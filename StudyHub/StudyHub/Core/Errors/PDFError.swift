import Foundation

enum PDFError: StudyHubError {
    case invalidURL
    case documentLoadFailed

    var title: String {
        switch self {
        case .invalidURL: return "Invalid File"
        case .documentLoadFailed: return "Unable to Open PDF"
        }
    }

    var message: String {
        switch self {
        case .invalidURL: return "This attachment doesn't have a valid file reference."
        case .documentLoadFailed: return "This PDF could not be opened."
        }
    }

    var recoverySuggestion: String? {
        "Please try again."
    }
}
