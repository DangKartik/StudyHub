import Foundation

@MainActor
@Observable
final class ResourceViewModel {
    private let course: Course
    private let resourceRepository: any ResourceRepositoryProtocol

    private(set) var resources: [Resource] = []
    private(set) var loadError: StudyHubError?

    init(course: Course, resourceRepository: any ResourceRepositoryProtocol) {
        self.course = course
        self.resourceRepository = resourceRepository
    }

    func loadResources() {
        do {
            resources = try resourceRepository.fetch(forCourse: course)
            loadError = nil
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.fetchFailed(underlying: error)
        }
    }

    func createResource(
        title: String,
        type: ResourceType,
        url: String,
        notes: String
    ) {
        let resource = Resource(
            title: title,
            type: type,
            url: url,
            notes: notes
        )
        resource.course = course

        do {
            try resourceRepository.create(resource)
            loadResources()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func updateResource(
        _ resource: Resource,
        title: String,
        type: ResourceType,
        url: String,
        notes: String
    ) {
        resource.title = title
        resource.type = type
        resource.url = url
        resource.notes = notes
        resource.updatedAt = Date.now

        do {
            try resourceRepository.save()
            loadResources()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func deleteResource(_ resource: Resource) {
        do {
            try resourceRepository.delete(resource)
            loadResources()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.deleteFailed(underlying: error)
        }
    }

    /// Persists a PDF's PencilKit markup (Phase 3N.6.4) — no list reload
    /// needed, since markup data isn't shown in any Resource row.
    func saveMarkup(_ data: Data, for resource: Resource) {
        resource.markupData = data
        do {
            try resourceRepository.save()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }
}

extension ResourceType {
    var label: String {
        switch self {
        case .pdf: return "PDF"
        case .website: return "Website"
        case .book: return "Book"
        case .video: return "Video"
        case .repository: return "Repository"
        case .document: return "Document"
        }
    }
}
