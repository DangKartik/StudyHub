import Foundation

enum Priority: String, Codable, CaseIterable {
    case low
    case medium
    case high
    case critical
}

enum AssignmentStatus: String, Codable, CaseIterable {
    case notStarted
    case inProgress
    case submitted
    case completed
    case overdue
}

enum ReadingStatus: String, Codable, CaseIterable {
    case notStarted
    case reading
    case completed
}

enum QuestionType: String, Codable, CaseIterable {
    case questionAnswer
    case fillBlank
    case definition
    case diagram
    case image
    case essay
}

enum ResourceType: String, Codable, CaseIterable {
    case pdf
    case website
    case book
    case video
    case repository
    case document
}

enum StudyMode: String, Codable, CaseIterable {
    case flashcards
    case activeRecall
    case reading
    case mixed
}

enum SyncStatus: String, Codable, CaseIterable {
    case pending
    case synced
    case failed
}
