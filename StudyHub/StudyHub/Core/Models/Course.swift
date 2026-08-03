import Foundation
import SwiftData

@Model
final class Course {
    var id: UUID = UUID()
    var name: String = ""
    var courseCode: String = ""
    var courseColor: String = ""
    var instructor: String = ""
    var email: String = ""
    var secondInstructor: String = ""
    var secondInstructorEmail: String = ""
    var officeHours: String = ""
    var credits: Int = 0
    var goodNotesNotebookID: String?
    var notes: String = ""
    /// Raw `LetterGrade.rawValue`, set by hand once the course is fully
    /// graded — `nil` while still in progress. Feeds GPA directly; see
    /// `LetterGrade`'s doc comment for why this isn't derived from the
    /// in-progress percentage automatically.
    var finalLetterGrade: String?
    /// When true, `finalLetterGrade` is restricted to Pass/Fail (`.p`/`.f`)
    /// instead of the full A+–F scale, and this course is excluded from
    /// every GPA calculation entirely — a Pass/Fail course counts toward
    /// credits completed, never toward GPA, same as a real transcript.
    var isPassFail: Bool = false
    var isArchived: Bool = false
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now

    /// When the Course Page was last opened — `nil` until the first time.
    /// Distinct from `updatedAt` (which means "last *edited*" and is bumped
    /// by the edit form): a course you renamed but never opened would
    /// otherwise look falsely "recent" if ordering reused `updatedAt`. Set
    /// in `CourseDetailViewModel.load()`, read by `CoursesViewModel` to
    /// order each semester's course list by recency of viewing.
    var lastOpenedAt: Date?

    var semester: Semester?

    @Relationship(deleteRule: .cascade, inverse: \Lecture.course)
    var lectures: [Lecture] = []

    @Relationship(deleteRule: .cascade, inverse: \Assignment.course)
    var assignments: [Assignment] = []

    @Relationship(deleteRule: .cascade, inverse: \Reading.course)
    var readings: [Reading] = []

    @Relationship(deleteRule: .cascade, inverse: \Resource.course)
    var resources: [Resource] = []

    @Relationship(deleteRule: .cascade, inverse: \Assessment.course)
    var assessments: [Assessment] = []

    @Relationship(deleteRule: .cascade, inverse: \Flashcard.course)
    var flashcards: [Flashcard] = []

    /// Phase 4.2 (DECISION-036) — directly-owned Active Recall questions
    /// (no specific Lecture), same shape as `flashcards` above.
    @Relationship(deleteRule: .cascade, inverse: \ActiveRecallQuestion.course)
    var activeRecallQuestions: [ActiveRecallQuestion] = []

    @Relationship(deleteRule: .cascade, inverse: \Note.course)
    var noteEntries: [Note] = []

    /// Phase 4.3 (DECISION-037) — `.nullify`, not `.cascade`: ending/deleting
    /// a Course shouldn't destroy historical session records, same reasoning
    /// as every other "preserve user content" nullify rule in this project.
    @Relationship(deleteRule: .nullify, inverse: \StudySession.course)
    var studySessions: [StudySession] = []

    init(
        id: UUID = UUID(),
        name: String,
        courseCode: String,
        courseColor: String,
        instructor: String = "",
        email: String = "",
        secondInstructor: String = "",
        secondInstructorEmail: String = "",
        officeHours: String = "",
        credits: Int = 0,
        goodNotesNotebookID: String? = nil,
        notes: String = "",
        finalLetterGrade: String? = nil,
        isPassFail: Bool = false,
        isArchived: Bool = false,
        createdAt: Date = Date.now,
        updatedAt: Date = Date.now,
        lastOpenedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.courseCode = courseCode
        self.courseColor = courseColor
        self.instructor = instructor
        self.email = email
        self.secondInstructor = secondInstructor
        self.secondInstructorEmail = secondInstructorEmail
        self.officeHours = officeHours
        self.credits = credits
        self.goodNotesNotebookID = goodNotesNotebookID
        self.notes = notes
        self.finalLetterGrade = finalLetterGrade
        self.isPassFail = isPassFail
        self.finalLetterGrade = finalLetterGrade
        self.isArchived = isArchived
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastOpenedAt = lastOpenedAt
    }

    /// Both professors' names for display when a second one is set — e.g.
    /// "Dr Kartik, Dr Second" — falling back to just whichever one (or
    /// neither) is actually filled in otherwise.
    var instructorDisplayName: String {
        let trimmedFirst = instructor.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSecond = secondInstructor.trimmingCharacters(in: .whitespacesAndNewlines)
        switch (trimmedFirst.isEmpty, trimmedSecond.isEmpty) {
        case (false, false): return "\(trimmedFirst), \(trimmedSecond)"
        case (false, true): return trimmedFirst
        case (true, false): return trimmedSecond
        case (true, true): return ""
        }
    }

    /// (Name, mailto URL) for every professor who actually has a valid
    /// email set — lets a caller decide "one button" vs. "pick which one"
    /// without duplicating the mailto-validity check per professor.
    var emailableInstructors: [(name: String, url: URL)] {
        var result: [(name: String, url: URL)] = []
        if let url = URL.mailto(email) {
            result.append((instructor.isEmpty ? "Instructor" : instructor, url))
        }
        if let url = URL.mailto(secondInstructorEmail) {
            result.append((secondInstructor.isEmpty ? "Second Instructor" : secondInstructor, url))
        }
        return result
    }
}
