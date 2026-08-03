import Foundation

@MainActor
@Observable
final class AssignmentsViewModel {
    private let course: Course
    private let assignmentRepository: any AssignmentRepositoryProtocol
    private let notificationManager: any NotificationSchedulingProtocol
    private let calendarSyncService: any CalendarSyncServiceProtocol
    private let calendarRepository: any CalendarRepositoryProtocol
    private let userPreferences: UserPreferences

    private(set) var assignments: [Assignment] = []
    private(set) var loadError: StudyHubError?

    init(
        course: Course,
        assignmentRepository: any AssignmentRepositoryProtocol,
        notificationManager: any NotificationSchedulingProtocol,
        calendarSyncService: any CalendarSyncServiceProtocol,
        calendarRepository: any CalendarRepositoryProtocol,
        userPreferences: UserPreferences
    ) {
        self.course = course
        self.assignmentRepository = assignmentRepository
        self.notificationManager = notificationManager
        self.calendarSyncService = calendarSyncService
        self.calendarRepository = calendarRepository
        self.userPreferences = userPreferences
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
            scheduleDueSoonNotification(for: assignment)
            syncReminder(for: assignment)
            syncCalendarEvent(for: assignment)
            try? assignmentRepository.save()
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
            scheduleDueSoonNotification(for: assignment)
            syncReminder(for: assignment)
            syncCalendarEvent(for: assignment)
            try? assignmentRepository.save()
            loadAssignments()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func deleteAssignment(_ assignment: Assignment) {
        notificationManager.cancelNotification(id: dueSoonNotificationID(for: assignment))
        if let reminderReference = assignment.reminderReference {
            calendarSyncService.deleteReminder(identifier: reminderReference.eventIdentifier)
        }
        if let calendarReference = assignment.calendarEventReference {
            calendarSyncService.deleteEvent(identifier: calendarReference.eventIdentifier)
        }

        do {
            try assignmentRepository.delete(assignment)
            loadAssignments()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.deleteFailed(underlying: error)
        }
    }

    /// Pulls completion state from each tracked Reminder and reconciles it
    /// into `assignment.status` — the "round-trip" half of Reminders sync.
    /// Run on every `AssignmentListView.onAppear`, same "cheap, re-check on
    /// every appear, no separate throttling" approach the rest of this app
    /// already uses for its own reads.
    func reconcileReminderCompletion() {
        guard userPreferences.remindersSyncEnabled else { return }
        var didChange = false
        for assignment in assignments {
            guard let reference = assignment.reminderReference,
                  let isCompleted = calendarSyncService.reminderCompletion(identifier: reference.eventIdentifier) else { continue }
            let assignmentIsCompleted = assignment.status == .completed
            guard isCompleted != assignmentIsCompleted else { continue }
            assignment.status = isCompleted ? .completed : .notStarted
            assignment.updatedAt = .now
            if isCompleted {
                notificationManager.cancelNotification(id: dueSoonNotificationID(for: assignment))
            }
            didChange = true
        }
        guard didChange else { return }
        try? assignmentRepository.save()
        loadAssignments()
    }

    private func dueSoonNotificationID(for assignment: Assignment) -> String {
        "assignment-dueSoon-\(assignment.id)"
    }

    private func scheduleDueSoonNotification(for assignment: Assignment) {
        let id = dueSoonNotificationID(for: assignment)
        notificationManager.cancelNotification(id: id)
        guard userPreferences.notificationsEnabled, assignment.status != .completed else { return }
        let fireDate = Calendar.current.date(byAdding: .hour, value: -userPreferences.dueSoonReminderLeadHours, to: assignment.dueDate) ?? assignment.dueDate
        let courseLabel = course.name.isEmpty ? course.courseCode : course.name
        notificationManager.scheduleNotification(
            id: id,
            title: "Assignment Due Soon",
            body: courseLabel.isEmpty ? assignment.title : "\(assignment.title) — \(courseLabel)",
            date: fireDate
        )
    }

    private func syncReminder(for assignment: Assignment) {
        guard userPreferences.remindersSyncEnabled else { return }
        let identifier = calendarSyncService.upsertStudyHubReminder(
            existingIdentifier: assignment.reminderReference?.eventIdentifier,
            title: assignment.title,
            dueDate: assignment.dueDate,
            isCompleted: assignment.status == .completed
        )
        guard let identifier else { return }
        if let reference = assignment.reminderReference {
            reference.eventIdentifier = identifier
            reference.syncStatus = .synced
            reference.lastSynced = .now
        } else {
            let reference = CalendarEventReference(eventIdentifier: identifier, calendarIdentifier: "", lastSynced: .now, syncStatus: .synced)
            try? calendarRepository.create(reference)
            assignment.reminderReference = reference
        }
    }

    private func syncCalendarEvent(for assignment: Assignment) {
        guard userPreferences.calendarPushEnabled else { return }
        let identifier = calendarSyncService.upsertStudyHubEvent(
            existingIdentifier: assignment.calendarEventReference?.eventIdentifier,
            title: assignment.title,
            startDate: assignment.dueDate,
            endDate: assignment.dueDate,
            location: ""
        )
        guard let identifier else { return }
        if let reference = assignment.calendarEventReference {
            reference.eventIdentifier = identifier
            reference.syncStatus = .synced
            reference.lastSynced = .now
        } else {
            let reference = CalendarEventReference(eventIdentifier: identifier, calendarIdentifier: "", lastSynced: .now, syncStatus: .synced)
            try? calendarRepository.create(reference)
            assignment.calendarEventReference = reference
        }
    }

    func completeAssignment(_ assignment: Assignment) {
        assignment.status = .completed

        do {
            try assignmentRepository.save()
            notificationManager.cancelNotification(id: dueSoonNotificationID(for: assignment))
            syncReminder(for: assignment)
            try? assignmentRepository.save()
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
