import Foundation

@MainActor
@Observable
final class FlashcardsViewModel {
    private let course: Course
    private let flashcardRepository: any FlashcardRepositoryProtocol

    private(set) var flashcards: [Flashcard] = []
    private(set) var loadError: StudyHubError?

    init(course: Course, flashcardRepository: any FlashcardRepositoryProtocol) {
        self.course = course
        self.flashcardRepository = flashcardRepository
    }

    /// The course's own lectures, used to populate the optional Lecture picker.
    /// Read directly from the already-loaded relationship — no repository call
    /// needed since Course already owns this data in memory.
    var availableLectures: [Lecture] {
        course.lectures.sorted { $0.date < $1.date }
    }

    func loadFlashcards() {
        do {
            flashcards = try flashcardRepository.fetch(forCourse: course)
            loadError = nil
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.fetchFailed(underlying: error)
        }
    }

    func createFlashcard(front: String, back: String, lecture: Lecture?) {
        let flashcard = Flashcard(front: front, back: back)
        flashcard.course = course
        flashcard.lecture = lecture

        do {
            try flashcardRepository.create(flashcard)
            loadFlashcards()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func updateFlashcard(_ flashcard: Flashcard, front: String, back: String, lecture: Lecture?) {
        flashcard.front = front
        flashcard.back = back
        flashcard.lecture = lecture
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
