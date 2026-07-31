import Foundation

enum NoteFilter: String, CaseIterable, Identifiable {
    case all
    case courseOnly
    case lectureOnly
    case hasAttachments

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all: return "All Notes"
        case .courseOnly: return "Course Notes"
        case .lectureOnly: return "Lecture Notes"
        case .hasAttachments: return "Has Attachments"
        }
    }
}

enum NoteSortOrder: String, CaseIterable, Identifiable {
    case newestCreated
    case oldestCreated
    case recentlyEdited
    case oldestEdited

    var id: String { rawValue }

    var label: String {
        switch self {
        case .newestCreated: return "Newest Created"
        case .oldestCreated: return "Oldest Created"
        case .recentlyEdited: return "Recently Edited"
        case .oldestEdited: return "Oldest Edited"
        }
    }
}

@MainActor
@Observable
final class NotesViewModel {
    enum Scope {
        case course(Course)
        case lecture(Lecture)
        /// Cross-course "All Notes" browsing (Phase 3.1) — backed by
        /// `fetchAll()`, not a relationship walk. Read-only: notes have no
        /// unambiguous owner to assign from this scope, so creation is
        /// disabled here (see `supportsCreation`).
        case global
    }

    private let scope: Scope
    private let noteRepository: any NoteRepositoryProtocol

    private(set) var notes: [Note] = []
    private(set) var loadError: StudyHubError?

    init(scope: Scope, noteRepository: any NoteRepositoryProtocol) {
        self.scope = scope
        self.noteRepository = noteRepository
    }

    /// True when this screen represents a Course's Notes (as opposed to a
    /// single Lecture's Notes) — used to decide whether the creation form
    /// should offer an optional Lecture picker (see DECISION-030).
    var isCourseScope: Bool {
        if case .course = scope {
            return true
        }
        return false
    }

    /// The course's own lectures, used to populate the optional Lecture picker
    /// when creating from Course scope. Read directly from the already-loaded
    /// relationship, mirroring `FlashcardsViewModel.availableLectures`.
    var availableLectures: [Lecture] {
        if case .course(let course) = scope {
            return course.lectures.sorted { $0.date < $1.date }
        }
        return []
    }

    /// True for `.course`/`.lecture` scopes, which have an unambiguous owner
    /// to assign a new note to. `.global` has none (a note's owner is never
    /// inferred), so note creation is not offered from that scope.
    var supportsCreation: Bool {
        switch scope {
        case .course, .lecture:
            return true
        case .global:
            return false
        }
    }

    /// Every distinct tag across the already-loaded `notes` array, sorted —
    /// feeds the tag-filter menu. Client-side, matching `displayedNotes`.
    var allTags: [String] {
        Set(notes.flatMap(\.tags)).sorted()
    }

    /// Client-side filter + sort over the already-loaded `notes` array — no
    /// repository call needed, since aggregation already loaded the full
    /// candidate set. `searchText` matches title or body (case/diacritic
    /// insensitive); `tag`, when set, requires an exact match in the note's
    /// `tags` array. Both are in-memory per DECISION-031's foundation scope —
    /// no repository-level search is introduced.
    func displayedNotes(filter: NoteFilter, sortOrder: NoteSortOrder, searchText: String = "", tag: String? = nil) -> [Note] {
        var filtered: [Note]
        switch filter {
        case .all:
            filtered = notes
        case .courseOnly:
            filtered = notes.filter { $0.course != nil }
        case .lectureOnly:
            filtered = notes.filter { $0.lecture != nil }
        case .hasAttachments:
            filtered = notes.filter { !$0.attachments.isEmpty }
        }

        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedSearch.isEmpty {
            filtered = filtered.filter {
                $0.title.localizedStandardContains(trimmedSearch) || $0.body.localizedStandardContains(trimmedSearch)
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
        case .recentlyEdited:
            return filtered.sorted { $0.updatedAt > $1.updatedAt }
        case .oldestEdited:
            return filtered.sorted { $0.updatedAt < $1.updatedAt }
        }
    }

    func loadNotes() {
        do {
            switch scope {
            case .course(let course):
                notes = try noteRepository.fetch(forCourseIncludingLectures: course)
            case .lecture(let lecture):
                notes = try noteRepository.fetch(forLecture: lecture)
            case .global:
                notes = try noteRepository.fetchAll()
            }
            loadError = nil
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.fetchFailed(underlying: error)
        }
    }

    /// `lecture` is only meaningful when this screen's scope is `.course` — it
    /// lets Course Notes creation optionally target a specific Lecture instead
    /// (see DECISION-030). When scope is `.lecture`, the parameter is ignored
    /// and the note is attached to that Lecture exactly as before.
    ///
    /// `attachments` are staged, not-yet-inserted `Attachment` objects built
    /// while composing the note (e.g. an imported PDF picked before the note
    /// existed). A staged `.pdf` attachment's `url` holds a *temporary* path
    /// (see Phase 3N.4 Part 3) — it's finalized into permanent storage here,
    /// only once the note is actually being saved, before being linked and
    /// saved via the same `createAttachment(_:for:)` path `addAttachment` uses.
    func createNote(title: String, body: String, lecture: Lecture? = nil, tags: [String] = [], attachments: [Attachment] = []) {
        guard supportsCreation else { return }

        let note = Note(title: title, body: body)
        note.tags = tags
        switch scope {
        case .course(let course):
            if let lecture {
                note.lecture = lecture
            } else {
                note.course = course
            }
        case .lecture(let lecture):
            note.lecture = lecture
        case .global:
            return
        }

        do {
            try noteRepository.create(note)
            for attachment in attachments {
                if attachment.type == AttachmentKind.pdf.rawValue {
                    attachment.url = try AttachmentFileImporter.finalize(temporaryPath: attachment.url)
                }
                try noteRepository.createAttachment(attachment, for: note)
            }
            loadNotes()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    /// `tags`, when provided, replaces the note's tags entirely; `nil` (the
    /// default) leaves them unchanged — used by call sites that only edit
    /// title/body (e.g. the PDF summary editor) so they don't need to know
    /// or re-supply the current tag list just to save an unrelated edit.
    func updateNote(_ note: Note, title: String, body: String, tags: [String]? = nil) {
        note.title = title
        note.body = body
        if let tags {
            note.tags = tags
        }
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

    /// Persists a PDF's PencilKit markup (Phase 3N.6.4) — no list reload
    /// needed, since markup data isn't shown in any Note row.
    func saveMarkup(_ data: Data, for attachment: Attachment) {
        attachment.markupData = data
        do {
            try noteRepository.save()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }
}
