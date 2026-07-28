import Foundation

enum PersistenceError: StudyHubError {
    case saveFailed(underlying: Error)
    case fetchFailed(underlying: Error)
    case deleteFailed(underlying: Error)

    var title: String {
        switch self {
        case .saveFailed: return "Unable to Save"
        case .fetchFailed: return "Unable to Load"
        case .deleteFailed: return "Unable to Delete"
        }
    }

    var message: String {
        switch self {
        case .saveFailed: return "Your changes could not be saved."
        case .fetchFailed: return "Your data could not be loaded."
        case .deleteFailed: return "This item could not be deleted."
        }
    }

    var recoverySuggestion: String? {
        "Please try again."
    }
}

func persistenceSave<T>(_ operation: () throws -> T) throws -> T {
    do {
        return try operation()
    } catch {
        throw PersistenceError.saveFailed(underlying: error)
    }
}

func persistenceFetch<T>(_ operation: () throws -> T) throws -> T {
    do {
        return try operation()
    } catch {
        throw PersistenceError.fetchFailed(underlying: error)
    }
}

func persistenceDelete<T>(_ operation: () throws -> T) throws -> T {
    do {
        return try operation()
    } catch {
        throw PersistenceError.deleteFailed(underlying: error)
    }
}
