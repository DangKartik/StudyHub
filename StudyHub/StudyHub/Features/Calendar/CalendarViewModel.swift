import Foundation
import SwiftUI

/// Backs the sidebar's Calendar page — a month grid aggregating every
/// date-bearing item (Lectures, Assignments, Exams/Quizzes, Readings) across
/// the active semester's courses, same "real data, not a stub" direction as
/// Home. Read-only: this is a glanceable overview, not a second place to
/// edit things — tapping an item elsewhere still opens its real editor.
@MainActor
@Observable
final class CalendarViewModel {
    private let appState: AppState
    private let courseRepository: any CourseRepositoryProtocol
    private let assignmentRepository: any AssignmentRepositoryProtocol
    private let readingRepository: any ReadingRepositoryProtocol
    private let lectureRepository: any LectureRepositoryProtocol

    private(set) var itemsByDay: [Date: [CalendarItem]] = [:]
    private(set) var loadError: StudyHubError?
    private(set) var hasActiveSemester = false

    init(
        appState: AppState,
        courseRepository: any CourseRepositoryProtocol,
        assignmentRepository: any AssignmentRepositoryProtocol,
        readingRepository: any ReadingRepositoryProtocol,
        lectureRepository: any LectureRepositoryProtocol
    ) {
        self.appState = appState
        self.courseRepository = courseRepository
        self.assignmentRepository = assignmentRepository
        self.readingRepository = readingRepository
        self.lectureRepository = lectureRepository
    }

    func items(on day: Date) -> [CalendarItem] {
        itemsByDay[Calendar.current.startOfDay(for: day)] ?? []
    }

    func load() {
        guard let semester = appState.activeSemester else {
            hasActiveSemester = false
            itemsByDay = [:]
            return
        }
        hasActiveSemester = true

        do {
            let courses = try courseRepository.fetch(forSemester: semester).filter { !$0.isArchived }
            var items: [CalendarItem] = []
            for course in courses {
                items.append(contentsOf: try lectureRepository.fetch(forCourse: course).map { .lecture($0) })
                items.append(contentsOf: try assignmentRepository.fetch(forCourse: course).map { .assignment($0) })
                items.append(contentsOf: try courseRepository.fetchAssessments(for: course).map { .assessment($0) })
                items.append(contentsOf: try readingRepository.fetch(forCourse: course).compactMap { $0.dueDate != nil ? .reading($0) : nil })
            }
            itemsByDay = Dictionary(grouping: items) { Calendar.current.startOfDay(for: $0.date) }
            loadError = nil
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.fetchFailed(underlying: error)
        }
    }
}

enum CalendarItem: Identifiable {
    case lecture(Lecture)
    case assignment(Assignment)
    case assessment(Assessment)
    case reading(Reading)

    var id: String {
        switch self {
        case .lecture(let lecture): return "lecture-\(lecture.id)"
        case .assignment(let assignment): return "assignment-\(assignment.id)"
        case .assessment(let assessment): return "assessment-\(assessment.id)"
        case .reading(let reading): return "reading-\(reading.id)"
        }
    }

    var date: Date {
        switch self {
        case .lecture(let lecture): return lecture.date
        case .assignment(let assignment): return assignment.dueDate
        case .assessment(let assessment): return assessment.date
        case .reading(let reading): return reading.dueDate ?? .distantPast
        }
    }

    var title: String {
        switch self {
        case .lecture(let lecture): return lecture.title
        case .assignment(let assignment): return assignment.title
        case .assessment(let assessment): return assessment.title
        case .reading(let reading): return reading.title
        }
    }

    var courseLabel: String? {
        let course: Course?
        switch self {
        case .lecture(let lecture): course = lecture.course
        case .assignment(let assignment): course = assignment.course
        case .assessment(let assessment): course = assessment.course
        case .reading(let reading): course = reading.course
        }
        guard let course else { return nil }
        return course.name.isEmpty ? course.courseCode : course.name
    }

    var icon: String {
        switch self {
        case .lecture: return "list.bullet"
        case .assignment: return "checklist"
        case .assessment(let assessment): return assessment.kind.icon
        case .reading: return "book.fill"
        }
    }

    var tint: Color {
        switch self {
        case .lecture: return .pink
        case .assignment: return .indigo
        case .assessment(let assessment): return assessment.kind.color
        case .reading: return .orange
        }
    }

    var typeLabel: String {
        switch self {
        case .lecture: return "Lecture"
        case .assignment: return "Assignment"
        case .assessment(let assessment): return assessment.kind.label
        case .reading: return "Reading"
        }
    }
}
