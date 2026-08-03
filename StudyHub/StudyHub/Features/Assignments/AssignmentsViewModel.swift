import Foundation

@MainActor
@Observable
final class AssignmentsViewModel {
    private let course: Course
    private let assignmentRepository: any AssignmentRepositoryProtocol

    private(set) var assignments: [Assignment] = []
    private(set) var loadError: StudyHubError?

    init(course: Course, assignmentRepository: any AssignmentRepositoryProtocol) {
        self.course = course
        self.assignmentRepository = assignmentRepository
    }

    var activeAssignments: [Assignment] {
        assignments.filter { $0.status != .completed }
    }

    var completedAssignments: [Assignment] {
        assignments.filter { $0.status == .completed }
    }

    func loadAssignments() {
        do {
            assignments = try assignmentRepository.fetch(forCourse: course)
            loadError = nil
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.fetchFailed(underlying: error)
        }
    }

    func createAssignment(
        title: String,
        dueDate: Date,
        priority: Priority,
        status: AssignmentStatus,
        description: String,
        estimatedHours: Double,
        attachments: [Attachment] = []
    ) {
        let assignment = Assignment(
            title: title,
            assignmentDescription: description,
            priority: priority,
            status: status,
            dueDate: dueDate,
            estimatedHours: estimatedHours
        )
        assignment.course = course

        do {
            try assignmentRepository.create(assignment)
            for attachment in attachments {
                if AttachmentKind(rawValue: attachment.type)?.isFileBased == true {
                    attachment.url = try AttachmentFileImporter.finalize(temporaryPath: attachment.url)
                }
                try assignmentRepository.createAttachment(attachment, for: assignment)
            }
            loadAssignments()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func updateAssignment(
        _ assignment: Assignment,
        title: String,
        dueDate: Date,
        priority: Priority,
        status: AssignmentStatus,
        description: String,
        estimatedHours: Double
    ) {
        assignment.title = title
        assignment.dueDate = dueDate
        assignment.priority = priority
        assignment.status = status
        assignment.assignmentDescription = description
        assignment.estimatedHours = estimatedHours

        do {
            try assignmentRepository.save()
            loadAssignments()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func deleteAssignment(_ assignment: Assignment) {
        do {
            try assignmentRepository.delete(assignment)
            loadAssignments()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.deleteFailed(underlying: error)
        }
    }

    func completeAssignment(_ assignment: Assignment) {
        assignment.status = .completed

        do {
            try assignmentRepository.save()
            loadAssignments()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func addAttachment(to assignment: Assignment, filename: String, type: String, url: String) {
        let attachment = Attachment(filename: filename, type: type, url: url)

        do {
            try assignmentRepository.createAttachment(attachment, for: assignment)
            loadAssignments()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func deleteAttachment(_ attachment: Attachment) {
        do {
            try assignmentRepository.deleteAttachment(attachment)
            loadAssignments()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.deleteFailed(underlying: error)
        }
    }

    /// Persists a PDF attachment's PencilKit markup — matches
    /// `NotesViewModel.saveMarkup`/`LectureViewModel.saveMarkup`.
    func saveMarkup(_ data: Data, for attachment: Attachment) {
        attachment.markupData = data
        do {
            try assignmentRepository.save()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }
}

extension Priority {
    var label: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .critical: return "Critical"
        }
    }
}

extension AssignmentStatus {
    var label: String {
        switch self {
        case .notStarted: return "Not Started"
        case .inProgress: return "In Progress"
        case .submitted: return "Submitted"
        case .completed: return "Completed"
        case .overdue: return "Overdue"
        }
    }
}
