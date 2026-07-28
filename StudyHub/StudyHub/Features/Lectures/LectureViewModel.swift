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
        topic: String,
        date: Date,
        startTime: Date,
        endTime: Date,
        location: String,
        summary: String
    ) {
        let lecture = Lecture(
            title: "",
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
            loadLectures()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func updateLecture(
        _ lecture: Lecture,
        topic: String,
        date: Date,
        startTime: Date,
        endTime: Date,
        location: String,
        summary: String
    ) {
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
}
