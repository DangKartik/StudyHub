import Foundation

extension Date {
    private static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()

    var shortDateString: String {
        Date.shortDateFormatter.string(from: self)
    }
}
