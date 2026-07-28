import Foundation
import SwiftData

protocol FlashcardRepositoryProtocol {
    func create(_ flashcard: Flashcard) throws
    func fetchAll() throws -> [Flashcard]
    func fetch(id: UUID) throws -> Flashcard?
    func delete(_ flashcard: Flashcard) throws
    func save() throws
    func exists(id: UUID) throws -> Bool
    func count() throws -> Int

    func fetch(forCourse course: Course) throws -> [Flashcard]
    func fetch(forLecture lecture: Lecture) throws -> [Flashcard]
    func dueToday() throws -> [Flashcard]
    func search(query: String) throws -> [Flashcard]
}

@MainActor
final class FlashcardRepository: FlashcardRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func create(_ flashcard: Flashcard) throws {
        modelContext.insert(flashcard)
        try modelContext.save()
    }

    func fetchAll() throws -> [Flashcard] {
        let descriptor = FetchDescriptor<Flashcard>(sortBy: [SortDescriptor(\.createdAt)])
        return try modelContext.fetch(descriptor)
    }

    func fetch(id: UUID) throws -> Flashcard? {
        var descriptor = FetchDescriptor<Flashcard>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    func delete(_ flashcard: Flashcard) throws {
        modelContext.delete(flashcard)
        try modelContext.save()
    }

    func save() throws {
        try modelContext.save()
    }

    func exists(id: UUID) throws -> Bool {
        try fetch(id: id) != nil
    }

    func count() throws -> Int {
        try modelContext.fetchCount(FetchDescriptor<Flashcard>())
    }

    func fetch(forCourse course: Course) throws -> [Flashcard] {
        course.flashcards.sorted { $0.createdAt < $1.createdAt }
    }

    func fetch(forLecture lecture: Lecture) throws -> [Flashcard] {
        lecture.referencedFlashcards.sorted { $0.createdAt < $1.createdAt }
    }

    func dueToday() throws -> [Flashcard] {
        let startOfDay = Calendar.current.startOfDay(for: .now)
        guard let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }
        let descriptor = FetchDescriptor<Flashcard>(
            predicate: #Predicate { $0.nextReviewDate != nil && $0.nextReviewDate! < endOfDay }
        )
        return try modelContext.fetch(descriptor)
    }

    func search(query: String) throws -> [Flashcard] {
        let descriptor = FetchDescriptor<Flashcard>(
            predicate: #Predicate { flashcard in
                flashcard.front.localizedStandardContains(query) ||
                flashcard.back.localizedStandardContains(query) ||
                flashcard.tags.contains(where: { $0.localizedStandardContains(query) })
            }
        )
        return try modelContext.fetch(descriptor)
    }
}
