import Foundation

extension URL {
    static func mailto(_ email: String) -> URL? {
        guard !email.isEmpty else { return nil }
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = email
        return components.url
    }
}
