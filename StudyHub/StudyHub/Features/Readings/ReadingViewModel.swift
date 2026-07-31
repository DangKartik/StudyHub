import Foundation

@MainActor
@Observable
final class ReadingViewModel {
    private let course: Course
    private let readingRepository: any ReadingRepositoryProtocol

    private(set) var readings: [Reading] = []
    private(set) var loadError: StudyHubError?

    init(course: Course, readingRepository: any ReadingRepositoryProtocol) {
        self.course = course
        self.readingRepository = readingRepository
    }

    func loadReadings() {
        do {
            readings = try readingRepository.fetch(forCourse: course)
            loadError = nil
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.fetchFailed(underlying: error)
        }
    }

    /// `attachments` are staged, not-yet-inserted `Attachment` objects built
    /// while composing the Reading (mirrors `NotesViewModel.createNote`). A
    /// staged `.pdf` attachment's `url` holds a *temporary* path — it's
    /// finalized into permanent storage here, only once the Reading is
    /// actually being saved, before being linked via the same
    /// `createAttachment(_:for:)` path `addAttachment` uses.
    func createReading(
        title: String,
        author: String,
        pageCount: Int,
        currentPage: Int,
        estimatedMinutes: Int,
        dueDate: Date?,
        notes: String,
        attachments: [Attachment] = []
    ) {
        let reading = Reading(
            title: title,
            author: author,
            pageCount: pageCount,
            currentPage: currentPage,
            estimatedMinutes: estimatedMinutes,
            notes: notes,
            dueDate: dueDate
        )
        reading.course = course

        do {
            try readingRepository.create(reading)
            for attachment in attachments {
                if attachment.type == AttachmentKind.pdf.rawValue {
                    attachment.url = try AttachmentFileImporter.finalize(temporaryPath: attachment.url)
                }
                try readingRepository.createAttachment(attachment, for: reading)
            }
            loadReadings()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func updateReading(
        _ reading: Reading,
        title: String,
        author: String,
        pageCount: Int,
        currentPage: Int,
        estimatedMinutes: Int,
        dueDate: Date?,
        notes: String
    ) {
        reading.title = title
        reading.author = author
        reading.pageCount = pageCount
        reading.currentPage = currentPage
        reading.estimatedMinutes = estimatedMinutes
        reading.dueDate = dueDate
        reading.notes = notes

        do {
            try readingRepository.save()
            loadReadings()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func deleteReading(_ reading: Reading) {
        do {
            try readingRepository.delete(reading)
            loadReadings()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.deleteFailed(underlying: error)
        }
    }

    func addAttachment(to reading: Reading, filename: String, type: String, url: String) {
        let attachment = Attachment(filename: filename, type: type, url: url)

        do {
            try readingRepository.createAttachment(attachment, for: reading)
            loadReadings()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func deleteAttachment(_ attachment: Attachment) {
        do {
            try readingRepository.deleteAttachment(attachment)
            loadReadings()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.deleteFailed(underlying: error)
        }
    }

    /// Persists a PDF's PencilKit markup (Phase 3N.6.4) — no list reload
    /// needed, since markup data isn't shown in any Reading row.
    func saveMarkup(_ data: Data, for attachment: Attachment) {
        attachment.markupData = data
        do {
            try readingRepository.save()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }
}
