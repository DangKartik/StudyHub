import Foundation

@MainActor
@Observable
final class CoursesViewModel {
    private let appState: AppState
    private let courseRepository: any CourseRepositoryProtocol

    private(set) var courses: [Course] = []
    private(set) var loadError: StudyHubError?

    init(appState: AppState, courseRepository: any CourseRepositoryProtocol) {
        self.appState = appState
        self.courseRepository = courseRepository
    }

    var activeCourses: [Course] {
        courses.filter { !$0.isArchived }
    }

    var archivedCourses: [Course] {
        courses.filter(\.isArchived)
    }

    func loadCourses() {
        guard let semester = appState.activeSemester else {
            courses = []
            loadError = nil
            return
        }

        do {
            courses = try courseRepository.fetch(forSemester: semester)
            loadError = nil
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.fetchFailed(underlying: error)
        }
    }

    func createCourse(name: String, courseCode: String, instructor: String, credits: Int, color: String) {
        guard let semester = appState.activeSemester else { return }

        let course = Course(
            name: name,
            courseCode: courseCode,
            courseColor: color,
            instructor: instructor,
            credits: credits
        )
        course.semester = semester

        do {
            try courseRepository.create(course)
            loadCourses()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func updateCourse(
        _ course: Course,
        name: String,
        courseCode: String,
        instructor: String,
        credits: Int,
        color: String
    ) {
        course.name = name
        course.courseCode = courseCode
        course.instructor = instructor
        course.credits = credits
        course.courseColor = color

        do {
            try courseRepository.save()
            loadCourses()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func archive(_ course: Course) {
        do {
            try courseRepository.archive(course)
            loadCourses()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func unarchive(_ course: Course) {
        course.isArchived = false

        do {
            try courseRepository.save()
            loadCourses()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func deleteCourse(_ course: Course) {
        do {
            try courseRepository.delete(course)
            loadCourses()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.deleteFailed(underlying: error)
        }
    }
}
