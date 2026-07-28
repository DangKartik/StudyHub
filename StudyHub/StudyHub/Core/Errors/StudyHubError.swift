import Foundation

protocol StudyHubError: Error {
    var title: String { get }
    var message: String { get }
    var recoverySuggestion: String? { get }
}
