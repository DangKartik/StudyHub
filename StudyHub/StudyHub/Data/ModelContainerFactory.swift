import Foundation
import SwiftData

enum ModelContainerFactory {
    static func makeContainer() -> ModelContainer {
        let schema = Schema([
            Semester.self,
            Course.self,
            Lecture.self,
            Assignment.self,
            Reading.self,
            Resource.self,
            Quiz.self,
            Exam.self,
            GradeCategory.self,
            Flashcard.self,
            ActiveRecallQuestion.self,
            StudySession.self,
            Quote.self,
            StatisticsSnapshot.self,
            Attachment.self,
            CalendarEventReference.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
