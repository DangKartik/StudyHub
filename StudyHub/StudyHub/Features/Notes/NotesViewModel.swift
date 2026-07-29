import Foundation

@MainActor
@Observable
final class NotesViewModel {
    enum Scope {
        case course(Course)
        case lecture(Lecture)
    }

    private let scope: Scope
    private let noteRepository: any NoteRepositoryProtocol

    private(set) var notes: [Note] = []
    private(set) var loadError: StudyHubError?

    init(scope: Scope, noteRepository: any NoteRepositoryProtocol) {
        self.scope = scope
        self.noteRepository = noteRepository
    }

    func loadNotes() {
        do {
            switch scope {
            case .course(let course):
                notes = try noteRepository.fetch(forCourse: course)
            case .lecture(let lecture):
                notes = try noteRepository.fetch(forLecture: lecture)
            }
            loadError = nil
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.fetchFailed(underlying: error)
        }
    }

    func createNote(title: String, body: String) {
        let note = Note(title: title, body: body)
        switch scope {
        case .course(let course):
            note.course = course
        case .lecture(let lecture):
            note.lecture = lecture
        }

        do {
            try noteRepository.create(note)
            loadNotes()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func updateNote(_ note: Note, title: String, body: String) {
        note.title = title
        note.body = body
        note.updatedAt = Date.now

        do {
            try noteRepository.save()
            loadNotes()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func deleteNote(_ note: Note) {
        do {
            try noteRepository.delete(note)
            loadNotes()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.deleteFailed(underlying: error)
        }
    }

    func addAttachment(to note: Note, filename: String, type: String, url: String) {
        let attachment = Attachment(filename: filename, type: type, url: url)

        do {
            try noteRepository.createAttachment(attachment, for: note)
            loadNotes()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func deleteAttachment(_ attachment: Attachment) {
        do {
            try noteRepository.deleteAttachment(attachment)
            loadNotes()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.deleteFailed(underlying: error)
        }
    }
}
