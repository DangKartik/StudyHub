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

/// Shared across every attachable/importable slot in the app — Notes,
/// Readings, Lectures, Assignments, and Resources all use this one type
/// instead of each feature inventing its own (Resources used to have a
/// separate ResourceType with pdf/website/book/video/repository/document;
/// Attachment-owning features had pdf/image/document/goodnotes/link/other —
/// collapsed down to the three that actually mean something distinct: a
/// real imported file (pdf/image) or a URL (link).
enum AttachmentKind: String, CaseIterable {
    case pdf
    case link
    case image

    var label: String {
        switch self {
        case .pdf: return "PDF"
        case .link: return "Link"
        case .image: return "Image"
        }
    }

    /// Whether this kind represents a real imported file (staged then
    /// finalized into permanent storage, needs cleanup if discarded) as
    /// opposed to a plain reference string (Link) that's just typed in.
    var isFileBased: Bool {
        switch self {
        case .pdf, .image: return true
        case .link: return false
        }
    }
}

/// Hand-written rather than synthesized: `Resource.type` stores this enum
/// directly (not as a raw `String` the way `Attachment.type` does), so
/// SwiftData decodes it straight out of the persisted store on every
/// launch. A resource saved before this type was consolidated (from the
/// old `ResourceType`'s website/book/video/repository/document, or this
/// enum's own former goodnotes/document/other) still has one of those raw
/// strings sitting in the database — decoding it with the default
/// single-case-only initializer would crash the app on launch instead of
/// just falling back. Unrecognized values fall back to `.link`, since
/// every removed case was link-like in practice.
extension AttachmentKind: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = AttachmentKind(rawValue: rawValue) ?? .link
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

enum AssessmentKind: String, Codable, CaseIterable {
    case quiz
    case exam

    var label: String {
        switch self {
        case .quiz: return "Quiz"
        case .exam: return "Exam"
        }
    }

    var icon: String {
        switch self {
        case .quiz: return "pencil.and.list.clipboard"
        case .exam: return "graduationcap.fill"
        }
    }
}

/// NTU's 5.0-point scale (fixed/standardized) — set by hand per course once
/// a final grade is known, rather than derived from `Course`'s in-progress
/// percentage, since NTU grading is relative/curved per module with no
/// fixed university-wide percentage cutoffs. Stored on `Course` as a raw
/// `String?`, not this enum directly — same lesson as `AttachmentKind`'s
/// hand-written `Codable`: parsing a plain String in code survives a future
/// rename without a SwiftData composite-attribute decode crash.
enum LetterGrade: String, CaseIterable {
    case aPlus = "A+"
    case a = "A"
    case aMinus = "A-"
    case bPlus = "B+"
    case b = "B"
    case bMinus = "B-"
    case cPlus = "C+"
    case c = "C"
    case dPlus = "D+"
    case d = "D"
    case f = "F"
    /// Pass — only ever offered for a course marked `Course.isPassFail`,
    /// never mixed into the regular A+–F scale. `gradePoints` is never
    /// actually read for this case: `GPACalculator.gpa(for:)` excludes
    /// every Pass/Fail course from GPA math entirely, same as a real
    /// transcript.
    case p = "P"

    var gradePoints: Double {
        switch self {
        case .aPlus, .a: return 5.0
        case .aMinus: return 4.5
        case .bPlus: return 4.0
        case .b: return 3.5
        case .bMinus: return 3.0
        case .cPlus: return 2.5
        case .c: return 2.0
        case .dPlus: return 1.0
        case .d: return 0.5
        case .f: return 0.0
        case .p: return 0.0
        }
    }

    /// The regular A+-through-F scale offered for a normally-graded course.
    static var standardCases: [LetterGrade] {
        allCases.filter { $0 != .p }
    }

    /// Just Pass/Fail, offered when `Course.isPassFail` is set.
    static var passFailCases: [LetterGrade] {
        [.p, .f]
    }
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
