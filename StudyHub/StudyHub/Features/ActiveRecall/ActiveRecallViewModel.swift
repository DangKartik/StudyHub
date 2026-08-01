import Foundation

/// A question's last self-rated recall (Phase 4.2) — stored in
/// `ActiveRecallQuestion.difficulty` (see DECISION-035), 0 meaning unrated.
/// Unlike Flashcard's 3-level rating, Active Recall has an explicit
/// "Again" level (got it wrong / need to see it soon) distinct from having
/// never been reviewed at all. No scheduling behavior is attached to these
/// values; that's a later, separate spaced-repetition phase.
enum RecallRating: Int, CaseIterable, Identifiable {
    case again = 1
    case hard = 2
    case good = 3
    case easy = 4

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .again: return "Again"
        case .hard: return "Hard"
        case .good: return "Good"
        case .easy: return "Easy"
        }
    }
}

enum ActiveRecallSortOrder: String, CaseIterable, Identifiable {
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

/// The three Review Queue groupings (Phase 4.2, requirement 5) — sorting
/// only, no scheduling algorithm: which bucket a question falls into is
/// derived purely from its last rating/`lastReviewed`, not any computed due
/// date.
enum ActiveRecallQueueSection: CaseIterable, Identifiable {
    case reviewAgain
    case neverReviewed
    case recentlyReviewed

    var id: Self { self }

    var title: String {
        switch self {
        case .reviewAgain: return "Review Again"
        case .neverReviewed: return "Never Reviewed"
        case .recentlyReviewed: return "Recently Reviewed"
        }
    }

    fileprivate func matches(_ question: ActiveRecallQuestion) -> Bool {
        switch self {
        case .reviewAgain:
            return question.difficulty == RecallRating.again.rawValue
        case .neverReviewed:
            return question.lastReviewed == nil
        case .recentlyReviewed:
            return question.lastReviewed != nil && question.difficulty != RecallRating.again.rawValue
        }
    }
}

@MainActor
@Observable
final class ActiveRecallViewModel {
    enum Scope {
        case lecture(Lecture)
        /// Read-only aggregation across the Course's Lectures — no direct
        /// ownership to assign a new question to (DECISION-027/035), so
        /// creation is not offered from this scope.
        case course(Course)
        /// Cross-course "All Questions" browsing, mirroring
        /// `FlashcardsViewModel.Scope.global`. Also read-only.
        case global

        var course: Course? {
            switch self {
            case .lecture(let lecture): return lecture.course
            case .course(let course): return course
            case .global: return nil
            }
        }
    }

    private let scope: Scope
    private let activeRecallRepository: any ActiveRecallRepositoryProtocol
    private let noteRepository: any NoteRepositoryProtocol
    private let flashcardRepository: any FlashcardRepositoryProtocol

    private(set) var questions: [ActiveRecallQuestion] = []
    private(set) var loadError: StudyHubError?

    init(
        scope: Scope,
        activeRecallRepository: any ActiveRecallRepositoryProtocol,
        noteRepository: any NoteRepositoryProtocol,
        flashcardRepository: any FlashcardRepositoryProtocol
    ) {
        self.scope = scope
        self.activeRecallRepository = activeRecallRepository
        self.noteRepository = noteRepository
        self.flashcardRepository = flashcardRepository
    }

    /// Both Lecture and Course scope have an unambiguous owner to assign a
    /// new question to (Phase 4.2, DECISION-036 — ActiveRecallQuestion now
    /// has a direct `course` field, mirroring Flashcard). Only Global has
    /// none.
    var supportsCreation: Bool {
        switch scope {
        case .lecture, .course: return true
        case .global: return false
        }
    }

    /// True specifically for Course scope — used by the form to decide
    /// whether to show an optional Lecture picker at all (Lecture scope
    /// has an implied, fixed Lecture and shows no picker).
    var isCreatingFromCourseScope: Bool {
        if case .course = scope { return true }
        return false
    }

    /// Populates the optional Lecture picker the form shows only when
    /// creating from Course scope — "None" (the default) attaches the
    /// question directly to the Course, exactly like Flashcard's own
    /// optional Lecture picker.
    var availableLecturesForCreation: [Lecture] {
        if case .course(let course) = scope {
            return course.lectures.sorted { $0.date < $1.date }
        }
        return []
    }

    /// The question's Course — resolved via `scope` directly for Course
    /// scope, else via the (Lecture scope's) Lecture. Shown read-only in
    /// the form, mirroring how DECISION-034's Flashcard form handles Course.
    var resolvedCourse: Course? {
        scope.course
    }

    var allTags: [String] {
        Set(questions.flatMap(\.tags)).sorted()
    }

    /// Notes a question can optionally link to, scoped to `course` — mirrors
    /// `FlashcardsViewModel.availableNotes(for:)`.
    func availableNotes(for course: Course?) -> [Note] {
        guard let course else { return [] }
        return ((try? noteRepository.fetch(forCourseIncludingLectures: course)) ?? [])
            .sorted { $0.title < $1.title }
    }

    /// Flashcards a question can optionally link to, scoped to `course` —
    /// completes the Question -> Flashcard -> Note -> Course chain
    /// (requirement 6) without a duplicate Course field on the question.
    func availableFlashcards(for course: Course?) -> [Flashcard] {
        guard let course else { return [] }
        return ((try? flashcardRepository.fetch(forCourse: course)) ?? [])
            .sorted { $0.front < $1.front }
    }

    /// Client-side filter + sort over the already-loaded `questions` array —
    /// no repository-level search, mirroring `NotesViewModel`/`FlashcardsViewModel`.
    func displayedQuestions(
        searchText: String = "",
        tag: String? = nil,
        sortOrder: ActiveRecallSortOrder = .newestCreated
    ) -> [ActiveRecallQuestion] {
        var filtered = questions

        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedSearch.isEmpty {
            filtered = filtered.filter {
                $0.question.localizedStandardContains(trimmedSearch) || $0.answer.localizedStandardContains(trimmedSearch)
            }
        }

        if let tag {
            filtered = filtered.filter { $0.tags.contains(tag) }
        }

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

    /// Groups an already-filtered/sorted list into the three Review Queue
    /// sections (requirement 5) — sorting only, no scheduling algorithm.
    /// Empty sections are omitted.
    func queueSections(from questions: [ActiveRecallQuestion]) -> [(section: ActiveRecallQueueSection, questions: [ActiveRecallQuestion])] {
        ActiveRecallQueueSection.allCases.compactMap { section in
            let matching = questions.filter { section.matches($0) }
            return matching.isEmpty ? nil : (section, matching)
        }
    }

    func loadQuestions() {
        do {
            switch scope {
            case .lecture(let lecture):
                questions = try activeRecallRepository.fetch(forLecture: lecture)
            case .course(let course):
                questions = try activeRecallRepository.fetch(forCourse: course)
            case .global:
                questions = try activeRecallRepository.fetchAll()
            }
            loadError = nil
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.fetchFailed(underlying: error)
        }
    }

    /// `lecture` is required when creating from Course scope (the form only
    /// shows that picker there, per `availableLecturesForCreation`) and
    /// ignored when creating from Lecture scope, where the lecture is
    /// already implied by `scope` itself.
    /// `lecture` is optional and only meaningful for Course scope — "None"
    /// attaches the question directly to the Course (DECISION-036), a
    /// picked Lecture attaches to that instead. Lecture scope ignores this
    /// param entirely, since the Lecture is already implied by `scope`.
    /// Mirrors `FlashcardsViewModel.createFlashcard` exactly.
    func createQuestion(
        question: String,
        answer: String,
        questionType: QuestionType,
        tags: [String],
        note: Note?,
        flashcard: Flashcard?,
        lecture: Lecture? = nil
    ) {
        guard supportsCreation else { return }

        let recallQuestion = ActiveRecallQuestion(question: question, answer: answer, questionType: questionType, tags: tags)
        switch scope {
        case .course(let course):
            if let lecture {
                recallQuestion.lecture = lecture
            } else {
                recallQuestion.course = course
            }
        case .lecture(let scopedLecture):
            recallQuestion.lecture = scopedLecture
        case .global:
            return
        }
        recallQuestion.note = note
        recallQuestion.flashcard = flashcard

        do {
            try activeRecallRepository.create(recallQuestion)
            loadQuestions()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func updateQuestion(
        _ recallQuestion: ActiveRecallQuestion,
        question: String,
        answer: String,
        questionType: QuestionType,
        tags: [String],
        note: Note?,
        flashcard: Flashcard?
    ) {
        recallQuestion.question = question
        recallQuestion.answer = answer
        recallQuestion.questionType = questionType
        recallQuestion.tags = tags
        recallQuestion.note = note
        recallQuestion.flashcard = flashcard
        recallQuestion.updatedAt = Date.now

        do {
            try activeRecallRepository.save()
            loadQuestions()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func deleteQuestion(_ recallQuestion: ActiveRecallQuestion) {
        do {
            try activeRecallRepository.delete(recallQuestion)
            loadQuestions()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.deleteFailed(underlying: error)
        }
    }
}

extension QuestionType {
    var label: String {
        switch self {
        case .questionAnswer: return "Question Answer"
        case .fillBlank: return "Fill Blank"
        case .definition: return "Definition"
        case .diagram: return "Diagram"
        case .image: return "Image"
        case .essay: return "Essay"
        }
    }
}
