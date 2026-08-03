import Foundation
import SwiftData

protocol CourseRepositoryProtocol {
    func create(_ course: Course) throws
    func fetchAll() throws -> [Course]
    func fetch(id: UUID) throws -> Course?
    func delete(_ course: Course) throws
    func save() throws
    func exists(id: UUID) throws -> Bool
    func count() throws -> Int

    func fetch(forSemester semester: Semester) throws -> [Course]
    func search(query: String) throws -> [Course]
    func archive(_ course: Course) throws

    func createAssessment(_ assessment: Assessment, for course: Course) throws
    func deleteAssessment(_ assessment: Assessment) throws
    func fetchAssessments(for course: Course) throws -> [Assessment]

    func createAttachment(_ attachment: Attachment, for assessment: Assessment) throws
    func deleteAttachment(_ attachment: Attachment) throws
}

@MainActor
final class CourseRepository: CourseRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func create(_ course: Course) throws {
        modelContext.insert(course)
        try persistenceSave { try modelContext.save() }
    }

    func fetchAll() throws -> [Course] {
        let descriptor = FetchDescriptor<Course>(sortBy: [SortDescriptor(\.name)])
        return try persistenceFetch { try modelContext.fetch(descriptor) }
    }

    func fetch(id: UUID) throws -> Course? {
        var descriptor = FetchDescriptor<Course>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try persistenceFetch { try modelContext.fetch(descriptor).first }
    }

    func delete(_ course: Course) throws {
        modelContext.delete(course)
        try persistenceDelete { try modelContext.save() }
    }

    func save() throws {
        try persistenceSave { try modelContext.save() }
    }

    func exists(id: UUID) throws -> Bool {
        try fetch(id: id) != nil
    }

    func count() throws -> Int {
        try persistenceFetch { try modelContext.fetchCount(FetchDescriptor<Course>()) }
    }

    func fetch(forSemester semester: Semester) throws -> [Course] {
        semester.courses.sorted { $0.name < $1.name }
    }

    func search(query: String) throws -> [Course] {
        let descriptor = FetchDescriptor<Course>(
            predicate: #Predicate {
                $0.name.localizedStandardContains(query) || $0.courseCode.localizedStandardContains(query)
            }
        )
        return try persistenceFetch { try modelContext.fetch(descriptor) }
    }

    func archive(_ course: Course) throws {
        course.isArchived = true
        try persistenceSave { try modelContext.save() }
    }

    func createAssessment(_ assessment: Assessment, for course: Course) throws {
        assessment.course = course
        modelContext.insert(assessment)
        try persistenceSave { try modelContext.save() }
    }

    func deleteAssessment(_ assessment: Assessment) throws {
        modelContext.delete(assessment)
        try persistenceDelete { try modelContext.save() }
    }

    func fetchAssessments(for course: Course) throws -> [Assessment] {
        course.assessments.sorted { $0.date < $1.date }
    }

    func createAttachment(_ attachment: Attachment, for assessment: Assessment) throws {
        attachment.assessment = assessment
        modelContext.insert(attachment)
        try persistenceSave { try modelContext.save() }
    }

    func deleteAttachment(_ attachment: Attachment) throws {
        modelContext.delete(attachment)
        try persistenceDelete { try modelContext.save() }
    }
}
