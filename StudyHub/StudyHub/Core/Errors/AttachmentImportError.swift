import Foundation

enum AttachmentImportError: StudyHubError {
    case accessDenied
    case copyFailed

    var title: String {
        switch self {
        case .accessDenied: return "Unable to Access File"
        case .copyFailed: return "Import Failed"
        }
    }

    var message: String {
        switch self {
        case .accessDenied: return "StudyHub couldn't access the selected file."
        case .copyFailed: return "This file could not be imported."
        }
    }

    var recoverySuggestion: String? {
        "Please try again."
    }
}
