import Foundation
import SwiftData

@Model
final class Note {
    var id: UUID = UUID()
    var title: String = ""
    var body: String = ""
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now

    var course: Course?
    var lecture: Lecture?
    var reading: Reading?

    /// Filterable/displayable/editable in the global Notes list (Phase 3.1);
    /// full tag editor lives in NoteFormView (Phase 3.1 Tags follow-up).
    var tags: [String] = []

    /// Phase 3.1 foundation field — no UI sets this yet, reserved for a future
    /// PDF-linking phase. See DECISION-031.
    var sourcePage: Int?

    @Relationship(deleteRule: .cascade, inverse: \Attachment.note)
    var attachments: [Attachment] = []

    /// The note's single owner (DECISION-031): Lecture name, else Reading
    /// title, else Course name — exactly one is ever set. "Unfiled" for a
    /// note whose owner was nullified by a Reading deletion (DECISION-032).
    /// Single shared implementation for `NotesListView`'s row and
    /// `NoteDetailView`'s preview, both of which display it.
    var ownerContextLabel: String {
        if let lecture { return lecture.topic }
        if let reading { return reading.title }
        if let course { return course.name }
        return "Unfiled"
    }

    /// Whether this note has any owner at all — lets callers skip showing
    /// `ownerContextLabel`'s "Unfiled" fallback text entirely rather than
    /// displaying it as if it were meaningful context.
    var hasOwner: Bool {
        lecture != nil || reading != nil || course != nil
    }

    /// Whether this note has ever been saved with a real edit since creation
    /// — lets callers show "Edited <date>" only when true, "Created <date>"
    /// otherwise. Relies on `init` guaranteeing `createdAt == updatedAt`
    /// exactly at creation (not just "the same day"); comparing calendar
    /// days would hide a real same-day edit, and comparing two independent
    /// `Date.now` calls would flag every brand-new note as "edited".
    var hasBeenEdited: Bool {
        updatedAt != createdAt
    }

    /// Flashcards derived from this Note (Phase 4.1, DECISION-034).
    /// `.nullify`, not `.cascade` — deleting a Note shouldn't destroy
    /// Flashcards that merely reference it, same reasoning as
    /// DECISION-032's Reading -> Note relationship.
    @Relationship(deleteRule: .nullify, inverse: \Flashcard.note)
    var linkedFlashcards: [Flashcard] = []

    /// Active Recall questions derived from this Note (Phase 4.2,
    /// DECISION-035). `.nullify` for the same reason as `linkedFlashcards`.
    @Relationship(deleteRule: .nullify, inverse: \ActiveRecallQuestion.note)
    var linkedActiveRecallQuestions: [ActiveRecallQuestion] = []

    /// `updatedAt` defaults to `nil`, not a second independent `Date.now` —
    /// two separate `Date.now` evaluations are never bit-identical, which
    /// would make `hasBeenEdited` true the instant a note is created.
    /// Defaulting it to exactly `createdAt` instead guarantees a fresh note
    /// reads as un-edited until something actually changes it.
    init(
        id: UUID = UUID(),
        title: String,
        body: String = "",
        createdAt: Date = Date.now,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.createdAt = createdAt
        self.updatedAt = updatedAt ?? createdAt
    }
}
