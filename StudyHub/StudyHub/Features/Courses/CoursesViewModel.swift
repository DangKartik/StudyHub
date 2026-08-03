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
        sortedByRecency(
            courses.filter { !$0.isArchived && $0.semester?.id == appState.activeSemester?.id }
        )
    }

    /// Every non-active, non-archived semester — including ones with zero
    /// courses. Previously this only surfaced semesters that already had at
    /// least one course (grouped straight off the course list), so a
    /// semester you'd created but hadn't added anything to yet was
    /// completely invisible here. Sorted newest-first by start date.
    var otherSemesterCourses: [SemesterCourseGroup] {
        let activeID = appState.activeSemester?.id
        let otherSemesters = semesters.filter { !$0.isArchived && $0.id != activeID }
        return otherSemesters
            .map { semester in
                let semesterCourses = sortedByRecency(
                    courses.filter { !$0.isArchived && $0.semester?.id == semester.id }
                )
                return SemesterCourseGroup(semester: semester, courses: semesterCourses)
            }
            .sorted { $0.semester.startDate > $1.semester.startDate }
    }

    /// Most-recently-opened first (`Course.lastOpenedAt`, bumped by
    /// `CourseDetailViewModel.load()`); a course never opened has no
    /// timestamp to rank by, so those fall after every opened course,
    /// alphabetically among themselves — same fallback used everywhere else
    /// in this list.
    private func sortedByRecency(_ courses: [Course]) -> [Course] {
        courses.sorted { lhs, rhs in
            switch (lhs.lastOpenedAt, rhs.lastOpenedAt) {
            case (let l?, let r?): return l > r
            case (nil, nil): return lhs.name < rhs.name
            case (nil, _): return false
            case (_, nil): return true
            }
        }
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
