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

    func createReading(
        title: String,
        author: String,
        pageCount: Int,
        currentPage: Int,
        estimatedMinutes: Int,
        dueDate: Date?,
        notes: String
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
}
