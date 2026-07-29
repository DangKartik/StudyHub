import Foundation

@MainActor
@Observable
final class CoursesViewModel {
    private let appState: AppState
    private let courseRepository: any CourseRepositoryProtocol
    private let semesterRepository: any SemesterRepositoryProtocol

    private(set) var courses: [Course] = []
    private(set) var semesters: [Semester] = []
    private(set) var loadError: StudyHubError?

    init(
        appState: AppState,
        courseRepository: any CourseRepositoryProtocol,
        semesterRepository: any SemesterRepositoryProtocol
    ) {
        self.appState = appState
        self.courseRepository = courseRepository
        self.semesterRepository = semesterRepository
    }

    struct SemesterCourseGroup: Identifiable {
        let semester: Semester
        let courses: [Course]
        var id: UUID { semester.id }
    }

    var activeSemester: Semester? {
        appState.activeSemester
    }

    var activeCourses: [Course] {
        courses
            .filter { !$0.isArchived && $0.semester?.id == appState.activeSemester?.id }
            .sorted { $0.name < $1.name }
    }

    var otherSemesterCourses: [SemesterCourseGroup] {
        let activeID = appState.activeSemester?.id
        let others = courses.filter {
            !$0.isArchived && $0.semester != nil && $0.semester?.id != activeID
        }
        let grouped = Dictionary(grouping: others) { $0.semester!.id }
        return grouped.values
            .compactMap { group -> SemesterCourseGroup? in
                guard let semester = group.first?.semester else { return nil }
                return SemesterCourseGroup(semester: semester, courses: group.sorted { $0.name < $1.name })
            }
            .sorted { $0.semester.startDate > $1.semester.startDate }
    }

    var archivedCourses: [Course] {
        courses.filter(\.isArchived)
    }

    func loadCourses() {
        do {
            courses = try courseRepository.fetchAll()
            semesters = try semesterRepository.fetchAll()
            loadError = nil
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.fetchFailed(underlying: error)
        }
    }

    func createCourse(
        name: String,
        courseCode: String,
        instructor: String,
        email: String,
        secondInstructor: String,
        secondInstructorEmail: String,
        credits: Int,
        color: String
    ) {
        guard let semester = appState.activeSemester else { return }

        let course = Course(
            name: name,
            courseCode: courseCode,
            courseColor: color,
            instructor: instructor,
            email: email,
            secondInstructor: secondInstructor,
            secondInstructorEmail: secondInstructorEmail,
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
        email: String,
        secondInstructor: String,
        secondInstructorEmail: String,
        credits: Int,
        color: String,
        semester: Semester
    ) {
        course.name = name
        course.courseCode = courseCode
        course.instructor = instructor
        course.email = email
        course.secondInstructor = secondInstructor
        course.secondInstructorEmail = secondInstructorEmail
        course.credits = credits
        course.courseColor = color
        course.semester = semester

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
