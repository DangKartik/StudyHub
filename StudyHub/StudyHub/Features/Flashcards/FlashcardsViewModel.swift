import Foundation

/// A card's last self-rated recall (Phase 4.1) — stored directly in
/// `Flashcard.difficulty` (see DECISION-034), 0 meaning unrated.
/// `.again` was added in Phase 4.4 (DECISION-038) to support real SM-2
/// scheduling, which needs a fourth "didn't recall it at all" level
/// distinct from "recalled it, but with difficulty" (`.hard`). Given
/// rawValue 4 (not inserted before `.hard`) so every already-stored
/// `difficulty` value from before this phase keeps its exact old meaning —
/// no migration needed.
enum FlashcardRating: Int, CaseIterable, Identifiable {
    case hard = 1
    case good = 2
    case easy = 3
    case again = 4

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .again: return "Again"
        case .hard: return "Hard"
        case .good: return "Good"
        case .easy: return "Easy"
        }
    }

    /// Converts to the feature-agnostic grade `SpacedRepetitionScheduler`
    /// actually schedules from (Phase 4.4).
    var reviewGrade: ReviewGrade {
        switch self {
        case .again: return .again
        case .hard: return .hard
        case .good: return .good
        case .easy: return .easy
        }
    }
}

enum FlashcardRatingFilter: String, CaseIterable, Identifiable {
    case all
    case unrated
    case again
    case hard
    case good
    case easy

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all: return "All Cards"
        case .unrated: return "Unrated"
        case .again: return "Rated Again"
        case .hard: return "Rated Hard"
        case .good: return "Rated Good"
        case .easy: return "Rated Easy"
        }
    }

    fileprivate func matches(_ flashcard: Flashcard) -> Bool {
        switch self {
        case .all: return true
        case .unrated: return flashcard.difficulty == 0
        case .again: return flashcard.difficulty == FlashcardRating.again.rawValue
        case .hard: return flashcard.difficulty == FlashcardRating.hard.rawValue
        case .good: return flashcard.difficulty == FlashcardRating.good.rawValue
        case .easy: return flashcard.difficulty == FlashcardRating.easy.rawValue
        }
    }
}

enum FlashcardSortOrder: String, CaseIterable, Identifiable {
    case newestCreated
    case oldestCreated
    case recentlyReviewed
    case oldestReviewed

    var id: String { rawValue }

    var label: String {
        switch self {
        case .newestCreated: return "Newest Created"
        case .oldestCreated: return "Oldest Created"
        case .recentlyReviewed: return "Recently Reviewed"
        case .oldestReviewed: return "Oldest Reviewed"
        }
    }
}

@MainActor
@Observable
final class FlashcardsViewModel {
    enum Scope {
        case course(Course)
        case lecture(Lecture)
        /// Cross-course "All Flashcards" browsing (Phase 4.1), mirroring
        /// `NotesViewModel.Scope.global` (DECISION-031). Read-only browse +
        /// review: a flashcard has no unambiguous owner to assign from this
        /// scope, so creation is disabled here — same restriction Notes
        /// already has, for the same reason.
        case global
    }

    private let scope: Scope
    private let flashcardRepository: any FlashcardRepositoryProtocol
    private let noteRepository: any NoteRepositoryProtocol

    private(set) var flashcards: [Flashcard] = []
    private(set) var loadError: StudyHubError?

    init(
        scope: Scope,
        flashcardRepository: any FlashcardRepositoryProtocol,
        noteRepository: any NoteRepositoryProtocol
    ) {
        self.scope = scope
        self.flashcardRepository = flashcardRepository
        self.noteRepository = noteRepository
    }

    /// The card's resolved Course, shown read-only in the form — Course
    /// association happens via scope (mirroring how Notes handles it), not
    /// an editable picker.
    var resolvedCourse: Course? {
        switch scope {
        case .course(let course): return course
        case .lecture(let lecture): return lecture.course
        case .global: return nil
        }
    }

    /// True for `.course`/`.lecture` scopes, which have an unambiguous owner
    /// to assign a new card to. `.global` has none, so creation is not
    /// offered from that scope — same restriction as Notes.
    var supportsCreation: Bool {
        switch scope {
        case .course, .lecture: return true
        case .global: return false
        }
    }

    /// Every distinct tag across the already-loaded `flashcards`, sorted —
    /// feeds the tag-filter menu.
    var allTags: [String] {
        Set(flashcards.flatMap(\.tags)).sorted()
    }

    /// Every distinct Course among the already-loaded `flashcards` — only
    /// meaningful (and only shown) in `.global` scope, where more than one
    /// course's cards can be mixed together.
    var allCourses: [Course] {
        var seen = Set<UUID>()
        var result: [Course] = []
        for flashcard in flashcards {
            if let course = flashcard.course, !seen.contains(course.id) {
                seen.insert(course.id)
                result.append(course)
            }
        }
        return result.sorted { $0.name < $1.name }
    }

    /// Notes a card can optionally link to — scoped to `course`, matching
    /// `availableLectures`' containment convention, so a Flashcard only ever
    /// links to a Note within its own Course.
    func availableNotes(for course: Course?) -> [Note] {
        guard let course else { return [] }
        return ((try? noteRepository.fetch(forCourseIncludingLectures: course)) ?? [])
            .sorted { $0.title < $1.title }
    }

    /// Client-side filter + sort over the already-loaded `flashcards` array
    /// — no repository-level search, mirroring `NotesViewModel.displayedNotes`.
    func displayedFlashcards(
        searchText: String = "",
        tag: String? = nil,
        course: Course? = nil,
        ratingFilter: FlashcardRatingFilter = .all,
        sortOrder: FlashcardSortOrder = .newestCreated
    ) -> [Flashcard] {
        var filtered = flashcards

        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedSearch.isEmpty {
            filtered = filtered.filter {
                $0.front.localizedStandardContains(trimmedSearch) || $0.back.localizedStandardContains(trimmedSearch)
            }
        }

        if let tag {
            filtered = filtered.filter { $0.tags.contains(tag) }
        }

        if let course {
            filtered = filtered.filter { $0.course?.id == course.id }
        }

        filtered = filtered.filter { ratingFilter.matches($0) }

        switch sortOrder {
        case .newestCreated:
            return filtered.sorted { $0.createdAt > $1.createdAt }
        case .oldestCreated:
            return filtered.sorted { $0.createdAt < $1.createdAt }
        case .recentlyReviewed:
            return filtered.sorted { ($0.lastReviewed ?? .distantPast) > ($1.lastReviewed ?? .distantPast) }
        case .oldestReviewed:
            return filtered.sorted { ($0.lastReviewed ?? .distantPast) < ($1.lastReviewed ?? .distantPast) }
        }
    }

    /// Groups an already-filtered/sorted list into the shared
    /// `DueQueueSection` buckets (Phase 4.4, DECISION-038), keyed on the
    /// real SM-2 schedule instead of the old placeholder "last rating"
    /// grouping. Empty sections are omitted. Mirrors
    /// `ActiveRecallViewModel.queueSections(from:)`.
    func queueSections(from flashcards: [Flashcard]) -> [(section: DueQueueSection, flashcards: [Flashcard])] {
        DueQueueSection.allCases.compactMap { section in
            let matching = flashcards.filter { DueQueueSection.classify(nextReviewDate: $0.nextReviewDate) == section }
            return matching.isEmpty ? nil : (section, matching)
        }
    }

    /// The subset of `flashcards` that belong in a "due now" review session
    /// (Phase 4.4, requirement 3/6) — due today or never reviewed. Drives
    /// the list's "Review" button default instead of reviewing every card.
    func dueFlashcards(from flashcards: [Flashcard]) -> [Flashcard] {
        flashcards.filter { DueQueueSection.classify(nextReviewDate: $0.nextReviewDate).isDueNow }
    }

    func loadFlashcards() {
        do {
            switch scope {
            case .course(let course):
                flashcards = try flashcardRepository.fetch(forCourse: course)
            case .lecture(let lecture):
                flashcards = try flashcardRepository.fetch(forLecture: lecture)
            case .global:
                flashcards = try flashcardRepository.fetchAll()
            }
            loadError = nil
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.fetchFailed(underlying: error)
        }
    }

    func createFlashcard(front: String, back: String, lecture: Lecture?, tags: [String], note: Note?) {
        guard supportsCreation else { return }

        let flashcard = Flashcard(front: front, back: back, tags: tags)
        switch scope {
        case .course(let course):
            if let lecture {
                flashcard.lecture = lecture
            } else {
                flashcard.course = course
            }
        case .lecture(let lecture):
            flashcard.lecture = lecture
        case .global:
            return
        }
        flashcard.note = note

        do {
            try flashcardRepository.create(flashcard)
            loadFlashcards()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func updateFlashcard(_ flashcard: Flashcard, front: String, back: String, lecture: Lecture?, tags: [String], note: Note?) {
        flashcard.front = front
        flashcard.back = back
        flashcard.lecture = lecture
        flashcard.tags = tags
        flashcard.note = note
        flashcard.updatedAt = Date.now

        do {
            try flashcardRepository.save()
            loadFlashcards()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func deleteFlashcard(_ flashcard: Flashcard) {
        do {
            try flashcardRepository.delete(flashcard)
            loadFlashcards()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.deleteFailed(underlying: error)
        }
    }
}
