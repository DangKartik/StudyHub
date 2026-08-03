import Foundation

@MainActor
@Observable
final class ReadingViewModel {
    private let course: Course
    private let readingRepository: any ReadingRepositoryProtocol
    private let pdfProgressRepository: any PDFProgressRepositoryProtocol
    private let notificationManager: any NotificationSchedulingProtocol
    private let userPreferences: UserPreferences

    private(set) var readings: [Reading] = []
    private(set) var loadError: StudyHubError?

    init(
        course: Course,
        readingRepository: any ReadingRepositoryProtocol,
        pdfProgressRepository: any PDFProgressRepositoryProtocol,
        notificationManager: any NotificationSchedulingProtocol,
        userPreferences: UserPreferences
    ) {
        self.course = course
        self.readingRepository = readingRepository
        self.pdfProgressRepository = pdfProgressRepository
        self.notificationManager = notificationManager
        self.userPreferences = userPreferences
    }

    func loadReadings() {
        do {
            // Due Today outranks Due Soon outranks Not Due everywhere a
            // Reading is listed — within the same tier, soonest due date
            // first, then alphabetical for readings with no due date at all.
            readings = try readingRepository.fetch(forCourse: course).sorted { lhs, rhs in
                if lhs.dueStatus != rhs.dueStatus {
                    return lhs.dueStatus < rhs.dueStatus
                }
                if let lhsDate = lhs.dueDate, let rhsDate = rhs.dueDate, lhsDate != rhsDate {
                    return lhsDate < rhsDate
                }
                return lhs.title < rhs.title
            }
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
    /// `createAttachment(_:for:)` path `addAttachment` uses. No page
    /// count/current page/estimated minutes here — those were manually
    /// entered fields that are now derived automatically from the PDF itself
    /// (see `progress(for:)`), not stored on `Reading`.
    func createReading(
        title: String,
        author: String,
        dueDate: Date?,
        notes: String,
        attachments: [Attachment] = []
    ) {
        let reading = Reading(
            title: title,
            author: author,
            notes: notes,
            dueDate: dueDate
        )
        reading.course = course

        do {
            try readingRepository.create(reading)
            for attachment in attachments {
                if AttachmentKind(rawValue: attachment.type)?.isFileBased == true {
                    attachment.url = try AttachmentFileImporter.finalize(temporaryPath: attachment.url)
                }
                try readingRepository.createAttachment(attachment, for: reading)
            }
            scheduleDueSoonNotification(for: reading)
            loadReadings()
            NotificationCenter.default.post(name: .readingsDidChange, object: nil)
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
        dueDate: Date?,
        notes: String
    ) {
        reading.title = title
        reading.author = author
        reading.dueDate = dueDate
        reading.notes = notes

        do {
            try readingRepository.save()
            scheduleDueSoonNotification(for: reading)
            loadReadings()
            NotificationCenter.default.post(name: .readingsDidChange, object: nil)
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func deleteReading(_ reading: Reading) {
        notificationManager.cancelNotification(id: dueSoonNotificationID(for: reading))
        do {
            try readingRepository.delete(reading)
            loadReadings()
            NotificationCenter.default.post(name: .readingsDidChange, object: nil)
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.deleteFailed(underlying: error)
        }
    }

    private func dueSoonNotificationID(for reading: Reading) -> String {
        "reading-dueSoon-\(reading.id)"
    }

    /// Fires relative to the *start of the due day*, not the raw `dueDate`
    /// timestamp — Reading's due date has no time picker, so the stored
    /// `Date` carries an arbitrary time-of-day left over from whenever the
    /// form was saved (see `Reading.dueStatus`, which treats it the same
    /// way for calendar-day comparisons).
    private func scheduleDueSoonNotification(for reading: Reading) {
        let id = dueSoonNotificationID(for: reading)
        notificationManager.cancelNotification(id: id)
        guard userPreferences.notificationsEnabled, let dueDate = reading.dueDate else { return }
        let startOfDueDay = Calendar.current.startOfDay(for: dueDate)
        let fireDate = Calendar.current.date(byAdding: .hour, value: -userPreferences.dueSoonReminderLeadHours, to: startOfDueDay) ?? startOfDueDay
        let courseLabel = course.name.isEmpty ? course.courseCode : course.name
        notificationManager.scheduleNotification(
            id: id,
            title: "Reading Due Soon",
            body: courseLabel.isEmpty ? reading.title : "\(reading.title) — \(courseLabel)",
            date: fireDate
        )
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

    /// The reading's actual, automatically-tracked progress — read from
    /// `PDFProgress` (keyed by the PDF's own `sourceURL`, updated live by
    /// `PDFViewerViewModel` as the user reads), not from any field on
    /// `Reading` itself. `nil` for a Reading with no PDF attachment, or one
    /// that's never been opened yet — both cases mean "nothing to show,"
    /// per the "don't show progress for non-paginated content" rule.
    func progress(for reading: Reading) -> (pageIndex: Int, pageCount: Int)? {
        guard let attachment = reading.attachments.first(where: { AttachmentKind(rawValue: $0.type) == .pdf }) else {
            return nil
        }
        guard let progress = try? pdfProgressRepository.fetch(sourceURL: attachment.url), progress.pageCount > 0 else {
            return nil
        }
        return (progress.highestPageIndex, progress.pageCount)
    }
}
