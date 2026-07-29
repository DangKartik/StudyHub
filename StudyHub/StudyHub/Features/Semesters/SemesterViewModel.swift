import Foundation

@MainActor
@Observable
final class SemesterViewModel {
    private let appState: AppState
    private let semesterRepository: any SemesterRepositoryProtocol

    private(set) var semesters: [Semester] = []
    private(set) var loadError: StudyHubError?

    init(appState: AppState, semesterRepository: any SemesterRepositoryProtocol) {
        self.appState = appState
        self.semesterRepository = semesterRepository
    }

    var activeSemester: Semester? {
        appState.activeSemester
    }

    var archivedSemesters: [Semester] {
        semesters.filter(\.isArchived)
    }

    var otherSemesters: [Semester] {
        let activeID = appState.activeSemester?.id
        return semesters.filter { !$0.isArchived && $0.id != activeID }
    }

    func loadSemesters() {
        do {
            semesters = try semesterRepository.fetchAll()
            loadError = nil
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.fetchFailed(underlying: error)
        }
    }

    func createSemester(name: String, startDate: Date, endDate: Date, color: String) {
        let semester = Semester(name: name, startDate: startDate, endDate: endDate, color: color)
        do {
            try semesterRepository.create(semester)
            loadSemesters()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func setActive(_ semester: Semester) {
        do {
            try semesterRepository.setActive(semester)
            appState.update(activeSemester: semester)
            loadSemesters()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func archive(_ semester: Semester) {
        do {
            try semesterRepository.archive(semester)
            if appState.activeSemester?.id == semester.id {
                appState.update(activeSemester: nil)
            }
            loadSemesters()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func updateSemester(
        _ semester: Semester,
        name: String,
        startDate: Date,
        endDate: Date,
        color: String
    ) {
        semester.name = name
        semester.startDate = startDate
        semester.endDate = endDate
        semester.color = color

        do {
            try semesterRepository.save()
            loadSemesters()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func unarchive(_ semester: Semester) {
        semester.isArchived = false

        do {
            try semesterRepository.save()
            loadSemesters()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func deleteSemester(_ semester: Semester) {
        do {
            try semesterRepository.delete(semester)
            loadSemesters()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.deleteFailed(underlying: error)
        }
    }
}
