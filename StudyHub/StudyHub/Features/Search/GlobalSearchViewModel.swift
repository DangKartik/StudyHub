import Foundation

/// One matched item, tagged with enough to render a row and to open the
/// right destination — mirrors every other feature's own "which one did
/// they tap" pattern (e.g. `NotesListView`'s `NoteSheet`).
struct GlobalSearchResult: Identifiable {
    enum Kind {
        case note(Note)
        case flashcard(Flashcard)
        case question(ActiveRecallQuestion)
        case reading(Reading)
        case course(Course)
    }

    let id: UUID
    let kind: Kind
    let title: String
    let subtitle: String?
    let icon: String
    let sectionTitle: String
}

/// Search across every content type StudyHub has (Phase 4.5 follow-up) —
/// client-side substring matching over already-fetched data, the same
/// pattern `NotesViewModel.displayedNotes`/`FlashcardsViewModel
/// .displayedFlashcards` already use, since none of these repositories
/// expose a dedicated full-text search method. Wired to the sidebar's
/// existing `.search` destination, previously a dead stub.
@MainActor
@Observable
final class GlobalSearchViewModel {
    private let noteRepository: any NoteRepositoryProtocol
    private let flashcardRepository: any FlashcardRepositoryProtocol
    private let activeRecallRepository: any ActiveRecallRepositoryProtocol
    private let readingRepository: any ReadingRepositoryProtocol
    private let courseRepository: any CourseRepositoryProtocol

    private var notes: [Note] = []
    private var flashcards: [Flashcard] = []
    private var questions: [ActiveRecallQuestion] = []
    private var readings: [Reading] = []
    private var courses: [Course] = []

    private(set) var loadError: StudyHubError?

    /// Capped per type so one very common word doesn't drown every other
    /// content type out of the results list.
    private static let maxResultsPerType = 20

    init(
        noteRepository: any NoteRepositoryProtocol,
        flashcardRepository: any FlashcardRepositoryProtocol,
        activeRecallRepository: any ActiveRecallRepositoryProtocol,
        readingRepository: any ReadingRepositoryProtocol,
        courseRepository: any CourseRepositoryProtocol
    ) {
        self.noteRepository = noteRepository
        self.flashcardRepository = flashcardRepository
        self.activeRecallRepository = activeRecallRepository
        self.readingRepository = readingRepository
        self.courseRepository = courseRepository
    }

    func loadAll() {
        do {
            notes = try noteRepository.fetchAll()
            flashcards = try flashcardRepository.fetchAll()
            questions = try activeRecallRepository.fetchAll()
            readings = try readingRepository.fetchAll()
            courses = try courseRepository.fetchAll()
            loadError = nil
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.fetchFailed(underlying: error)
        }
    }

    func results(for query: String) -> [GlobalSearchResult] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        var results: [GlobalSearchResult] = []

        results += notes
            .filter {
                $0.title.localizedStandardContains(trimmed) || $0.body.localizedStandardContains(trimmed)
                    || matchesTags($0.tags, query: trimmed)
            }
            .prefix(Self.maxResultsPerType)
            .map {
                GlobalSearchResult(
                    id: $0.id,
                    kind: .note($0),
                    title: $0.title.isEmpty ? "Untitled Note" : $0.title,
                    subtitle: $0.ownerContextLabel,
                    icon: "note.text",
                    sectionTitle: "Notes"
                )
            }

        results += flashcards
            .filter {
                $0.front.localizedStandardContains(trimmed) || $0.back.localizedStandardContains(trimmed)
                    || matchesTags($0.tags, query: trimmed)
            }
            .prefix(Self.maxResultsPerType)
            .map {
                GlobalSearchResult(
                    id: $0.id,
                    kind: .flashcard($0),
                    title: $0.front,
                    subtitle: $0.back,
                    icon: "rectangle.stack",
                    sectionTitle: "Flashcards"
                )
            }

        results += questions
            .filter {
                $0.question.localizedStandardContains(trimmed) || $0.answer.localizedStandardContains(trimmed)
                    || matchesTags($0.tags, query: trimmed)
            }
            .prefix(Self.maxResultsPerType)
            .map {
                GlobalSearchResult(
                    id: $0.id,
                    kind: .question($0),
                    title: $0.question,
                    subtitle: $0.answer,
                    icon: "brain.head.profile",
                    sectionTitle: "Active Recall"
                )
            }

        results += readings
            .filter { $0.title.localizedStandardContains(trimmed) || $0.author.localizedStandardContains(trimmed) }
            .prefix(Self.maxResultsPerType)
            .map {
                GlobalSearchResult(
                    id: $0.id,
                    kind: .reading($0),
                    title: $0.title,
                    subtitle: $0.course?.name,
                    icon: "book",
                    sectionTitle: "Readings"
                )
            }

        results += courses
            .filter { $0.name.localizedStandardContains(trimmed) || $0.courseCode.localizedStandardContains(trimmed) }
            .prefix(Self.maxResultsPerType)
            .map {
                GlobalSearchResult(
                    id: $0.id,
                    kind: .course($0),
                    title: $0.name.isEmpty ? $0.courseCode : $0.name,
                    subtitle: $0.courseCode.isEmpty ? nil : $0.courseCode,
                    icon: "book.closed",
                    sectionTitle: "Courses"
                )
            }

        return results
    }

    /// Notes/Flashcards/Active Recall Questions all carry a `tags: [String]`
    /// — matches if the query is a substring of any one tag, so searching
    /// "exam" finds everything tagged "exam-prep" too, not just an exact
    /// tag match.
    private func matchesTags(_ tags: [String], query: String) -> Bool {
        tags.contains { $0.localizedCaseInsensitiveContains(query) }
    }
}
