import Foundation
import SwiftData

/// Replaces the former separate `Quiz` and `Exam` models — both ended up
/// wanting the exact same fields (location, duration, score), so `kind`
/// is now the only thing distinguishing them.
@Model
final class Assessment {
    var id: UUID = UUID()
    var title: String = ""
    var kind: AssessmentKind = AssessmentKind.quiz
    var date: Date = Date.now
    var location: String = ""
    var duration: TimeInterval = 0
    var weight: Double = 0
    var score: Double?
    var maximumScore: Double = 100
    var notes: String = ""
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now

    /// Personal "how did it go" reflection, separate from `score` — filled
    /// in via the post-assessment prompt, not the edit form.
    var reflectionRating: Int?
    var reflectionNote: String = ""
    /// Set when the user explicitly skips the reflection prompt, so it
    /// stops being asked again for this assessment (unlike an unanswered
    /// one, which keeps getting re-prompted every launch).
    var reflectionDismissedAt: Date?

    var course: Course?

    @Relationship(deleteRule: .cascade, inverse: \Attachment.assessment)
    var attachments: [Attachment] = []

    @Relationship(deleteRule: .cascade)
    var calendarEventReference: CalendarEventReference?

    init(
        id: UUID = UUID(),
        title: String,
        kind: AssessmentKind,
        date: Date,
        location: String = "",
        duration: TimeInterval = 0,
        weight: Double = 0,
        score: Double? = nil,
        maximumScore: Double = 100,
        notes: String = "",
        reflectionRating: Int? = nil,
        reflectionNote: String = "",
        reflectionDismissedAt: Date? = nil,
        createdAt: Date = Date.now,
        updatedAt: Date = Date.now
    ) {
        self.id = id
        self.title = title
        self.kind = kind
        self.date = date
        self.location = location
        self.duration = duration
        self.weight = weight
        self.score = score
        self.maximumScore = maximumScore
        self.notes = notes
        self.reflectionRating = reflectionRating
        self.reflectionNote = reflectionNote
        self.reflectionDismissedAt = reflectionDismissedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var isPast: Bool {
        date < Date.now
    }

    var hasReflected: Bool {
        reflectionRating != nil ||
        !reflectionNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        reflectionDismissedAt != nil
    }
}
