import Foundation

@MainActor
@Observable
final class GradesViewModel {
    private let course: Course
    private let courseRepository: any CourseRepositoryProtocol
    private let notificationManager: any NotificationSchedulingProtocol
    private let calendarSyncService: any CalendarSyncServiceProtocol
    private let calendarRepository: any CalendarRepositoryProtocol
    private let userPreferences: UserPreferences

    private(set) var assessments: [Assessment] = []
    private(set) var loadError: StudyHubError?

    init(
        course: Course,
        courseRepository: any CourseRepositoryProtocol,
        notificationManager: any NotificationSchedulingProtocol,
        calendarSyncService: any CalendarSyncServiceProtocol,
        calendarRepository: any CalendarRepositoryProtocol,
        userPreferences: UserPreferences
    ) {
        self.course = course
        self.courseRepository = courseRepository
        self.notificationManager = notificationManager
        self.calendarSyncService = calendarSyncService
        self.calendarRepository = calendarRepository
        self.userPreferences = userPreferences
    }

    var currentGrade: Double? {
        GradeCalculator.currentGradePercent(assessments: assessments)
    }

    var finalLetterGrade: LetterGrade? {
        course.finalLetterGrade.flatMap(LetterGrade.init(rawValue:))
    }

    var isPassFail: Bool {
        course.isPassFail
    }

    /// How much of the 100% weight pool is still unassigned —
    /// `excludingID` lets an edit form exclude the item currently being
    /// edited from its own total, so re-saving it at the same weight
    /// doesn't falsely read as "over."
    func remainingWeight(excludingID: UUID? = nil) -> Double {
        let excludedWeight = assessments.first { $0.id == excludingID }?.weight ?? 0
        let assigned = GradeCalculator.totalAssignedWeight(assessments: assessments)
        return max(0, 100 - (assigned - excludedWeight))
    }

    func loadGrades() {
        do {
            assessments = try courseRepository.fetchAssessments(for: course)
            loadError = nil
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.fetchFailed(underlying: error)
        }
    }

    func setFinalLetterGrade(_ letterGrade: LetterGrade?) {
        course.finalLetterGrade = letterGrade?.rawValue
        course.updatedAt = Date.now
        do {
            try courseRepository.save()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    /// Switching a course's grading style makes any already-set final
    /// grade meaningless in the other scale (a Pass/Fail course can't have
    /// "B+" as its grade, and a regular course can't have "P") — clearing
    /// it forces picking a real one from whichever scale now applies,
    /// rather than silently keeping a stale value.
    func setPassFail(_ isPassFail: Bool) {
        course.isPassFail = isPassFail
        course.finalLetterGrade = nil
        course.updatedAt = Date.now
        do {
            try courseRepository.save()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    // MARK: - Assessments (Quiz/Exam)

    func createAssessment(
        title: String,
        kind: AssessmentKind,
        date: Date,
        location: String,
        duration: TimeInterval,
        weight: Double,
        score: Double?,
        maximumScore: Double,
        notes: String,
        attachments: [Attachment] = []
    ) {
        let assessment = Assessment(
            title: title,
            kind: kind,
            date: date,
            location: location,
            duration: duration,
            weight: weight,
            score: score,
            maximumScore: maximumScore,
            notes: notes
        )

        do {
            try courseRepository.createAssessment(assessment, for: course)
            for attachment in attachments {
                if AttachmentKind(rawValue: attachment.type)?.isFileBased == true {
                    attachment.url = try AttachmentFileImporter.finalize(temporaryPath: attachment.url)
                }
                try courseRepository.createAttachment(attachment, for: assessment)
            }
            scheduleNotifications(for: assessment)
            syncCalendarEvent(for: assessment)
            try? courseRepository.save()
            loadGrades()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func updateAssessment(
        _ assessment: Assessment,
        title: String,
        kind: AssessmentKind,
        date: Date,
        location: String,
        duration: TimeInterval,
        weight: Double,
        score: Double?,
        maximumScore: Double,
        notes: String
    ) {
        assessment.title = title
        assessment.kind = kind
        assessment.date = date
        assessment.location = location
        assessment.duration = duration
        assessment.weight = weight
        assessment.score = score
        assessment.maximumScore = maximumScore
        assessment.notes = notes
        assessment.updatedAt = Date.now

        do {
            try courseRepository.save()
            scheduleNotifications(for: assessment)
            syncCalendarEvent(for: assessment)
            try? courseRepository.save()
            loadGrades()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func deleteAssessment(_ assessment: Assessment) {
        notificationManager.cancelNotifications(ids: [dueSoonNotificationID(for: assessment), reflectionNotificationID(for: assessment)])
        if let reference = assessment.calendarEventReference {
            calendarSyncService.deleteEvent(identifier: reference.eventIdentifier)
        }

        do {
            try courseRepository.deleteAssessment(assessment)
            loadGrades()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.deleteFailed(underlying: error)
        }
    }

    private func dueSoonNotificationID(for assessment: Assessment) -> String {
        "assessment-dueSoon-\(assessment.id)"
    }

    private func reflectionNotificationID(for assessment: Assessment) -> String {
        "assessment-reflection-\(assessment.id)"
    }

    /// Only `.exam` kind assessments get notifications — matches the
    /// existing "important upcoming" convention Home/Course Detail already
    /// use for exams vs. quizzes (see `HomeViewModel.upcomingExams`).
    private func scheduleNotifications(for assessment: Assessment) {
        let dueSoonID = dueSoonNotificationID(for: assessment)
        let reflectionID = reflectionNotificationID(for: assessment)
        notificationManager.cancelNotifications(ids: [dueSoonID, reflectionID])
        guard userPreferences.notificationsEnabled, assessment.kind == .exam else { return }

        let courseLabel = course.name.isEmpty ? course.courseCode : course.name
        let fireDate = Calendar.current.date(byAdding: .hour, value: -userPreferences.dueSoonReminderLeadHours, to: assessment.date) ?? assessment.date
        notificationManager.scheduleNotification(
            id: dueSoonID,
            title: "Exam Due Soon",
            body: courseLabel.isEmpty ? assessment.title : "\(assessment.title) — \(courseLabel)",
            date: fireDate
        )

        if userPreferences.examReflectionNudgeEnabled, !assessment.hasReflected {
            notificationManager.scheduleNotification(
                id: reflectionID,
                title: "How did it go?",
                body: courseLabel.isEmpty ? assessment.title : "\(assessment.title) — \(courseLabel)",
                date: assessment.date
            )
        }
    }

    private func syncCalendarEvent(for assessment: Assessment) {
        guard userPreferences.calendarPushEnabled, assessment.kind == .exam else { return }
        let endDate = assessment.duration > 0 ? assessment.date.addingTimeInterval(assessment.duration) : assessment.date
        let identifier = calendarSyncService.upsertStudyHubEvent(
            existingIdentifier: assessment.calendarEventReference?.eventIdentifier,
            title: assessment.title,
            startDate: assessment.date,
            endDate: endDate,
            location: assessment.location
        )
        guard let identifier else { return }
        if let reference = assessment.calendarEventReference {
            reference.eventIdentifier = identifier
            reference.syncStatus = .synced
            reference.lastSynced = .now
        } else {
            let reference = CalendarEventReference(eventIdentifier: identifier, calendarIdentifier: "", lastSynced: .now, syncStatus: .synced)
            try? calendarRepository.create(reference)
            assessment.calendarEventReference = reference
        }
    }

    func addAttachment(to assessment: Assessment, filename: String, type: String, url: String) {
        let attachment = Attachment(filename: filename, type: type, url: url)

        do {
            try courseRepository.createAttachment(attachment, for: assessment)
            loadGrades()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func deleteAttachment(_ attachment: Attachment) {
        do {
            try courseRepository.deleteAttachment(attachment)
            loadGrades()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.deleteFailed(underlying: error)
        }
    }

    /// Persists a reflection answered (or edited) from inside this course's
    /// own Grades tab — the same fields the post-assessment popup
    /// (`AssessmentReflectionView` via `RootView`) writes, just reachable
    /// again afterward instead of only appearing once on launch.
    func saveReflection(for assessment: Assessment, rating: Int?, note: String) {
        assessment.reflectionRating = rating
        assessment.reflectionNote = note
        assessment.updatedAt = Date.now
        do {
            try courseRepository.save()
            notificationManager.cancelNotification(id: reflectionNotificationID(for: assessment))
            loadGrades()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    /// Persists a PDF attachment's PencilKit markup — mirrors
    /// `LectureViewModel.saveMarkup`.
    func saveMarkup(_ data: Data, for attachment: Attachment) {
        attachment.markupData = data
        do {
            try courseRepository.save()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }
}
