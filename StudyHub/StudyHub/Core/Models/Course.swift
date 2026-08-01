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
    var isArchived: Bool = false
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now

    var semester: Semester?

    @Relationship(deleteRule: .cascade, inverse: \Lecture.course)
    var lectures: [Lecture] = []

    @Relationship(deleteRule: .cascade, inverse: \Assignment.course)
    var assignments: [Assignment] = []

    @Relationship(deleteRule: .cascade, inverse: \Reading.course)
    var readings: [Reading] = []

    @Relationship(deleteRule: .cascade, inverse: \Resource.course)
    var resources: [Resource] = []

    @Relationship(deleteRule: .cascade, inverse: \Quiz.course)
    var quizzes: [Quiz] = []

    @Relationship(deleteRule: .cascade, inverse: \Exam.course)
    var exams: [Exam] = []

    @Relationship(deleteRule: .cascade, inverse: \GradeCategory.course)
    var gradeCategories: [GradeCategory] = []

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
        isArchived: Bool = false,
        createdAt: Date = Date.now,
        updatedAt: Date = Date.now
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
        self.isArchived = isArchived
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
