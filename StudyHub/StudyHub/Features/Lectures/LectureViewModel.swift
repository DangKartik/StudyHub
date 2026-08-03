import Foundation

@MainActor
@Observable
final class LectureViewModel {
    private let course: Course
    private let lectureRepository: any LectureRepositoryProtocol

    private(set) var lectures: [Lecture] = []
    private(set) var loadError: StudyHubError?

    init(course: Course, lectureRepository: any LectureRepositoryProtocol) {
        self.course = course
        self.lectureRepository = lectureRepository
    }

    func loadLectures() {
        do {
            lectures = try lectureRepository.fetch(forCourse: course)
            loadError = nil
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.fetchFailed(underlying: error)
        }
    }

    func createLecture(
        title: String,
        topic: String,
        date: Date,
        startTime: Date,
        endTime: Date,
        location: String,
        summary: String,
        attachments: [Attachment] = []
    ) {
        let lecture = Lecture(
            title: title,
            topic: topic,
            date: date,
            startTime: startTime,
            endTime: endTime,
            location: location,
            summary: summary
        )
        lecture.course = course

        do {
            try lectureRepository.create(lecture)
            for attachment in attachments {
                if AttachmentKind(rawValue: attachment.type)?.isFileBased == true {
                    attachment.url = try AttachmentFileImporter.finalize(temporaryPath: attachment.url)
                }
                try lectureRepository.createAttachment(attachment, for: lecture)
            }
            loadLectures()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func updateLecture(
        _ lecture: Lecture,
        title: String,
        topic: String,
        date: Date,
        startTime: Date,
        endTime: Date,
        location: String,
        summary: String
    ) {
        lecture.title = title
        lecture.topic = topic
        lecture.date = date
        lecture.startTime = startTime
        lecture.endTime = endTime
        lecture.location = location
        lecture.summary = summary

        do {
            try lectureRepository.save()
            loadLectures()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func deleteLecture(_ lecture: Lecture) {
        do {
            try lectureRepository.delete(lecture)
            loadLectures()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.deleteFailed(underlying: error)
        }
    }

    func addAttachment(to lecture: Lecture, filename: String, type: String, url: String) {
        let attachment = Attachment(filename: filename, type: type, url: url)

        do {
            try lectureRepository.createAttachment(attachment, for: lecture)
            loadLectures()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func deleteAttachment(_ attachment: Attachment) {
        do {
            try lectureRepository.deleteAttachment(attachment)
            loadLectures()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.deleteFailed(underlying: error)
        }
    }

    /// Persists a PDF attachment's PencilKit markup — no list reload
    /// needed, matching `NotesViewModel.saveMarkup`.
    func saveMarkup(_ data: Data, for attachment: Attachment) {
        attachment.markupData = data
        do {
            try lectureRepository.save()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }
}
