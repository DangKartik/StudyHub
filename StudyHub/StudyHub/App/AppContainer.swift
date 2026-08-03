import SwiftData
import SwiftUI

@MainActor
final class AppContainer {
    let appState: AppState
    let userPreferences: UserPreferences
    let modelContainer: ModelContainer
    let navigationRouter: NavigationRouter

    let semesterRepository: any SemesterRepositoryProtocol
    let courseRepository: any CourseRepositoryProtocol
    let lectureRepository: any LectureRepositoryProtocol
    let assignmentRepository: any AssignmentRepositoryProtocol
    let readingRepository: any ReadingRepositoryProtocol
    let resourceRepository: any ResourceRepositoryProtocol
    let flashcardRepository: any FlashcardRepositoryProtocol
    let activeRecallRepository: any ActiveRecallRepositoryProtocol
    let noteRepository: any NoteRepositoryProtocol
    let studySessionRepository: any StudySessionRepositoryProtocol
    let statisticsRepository: any StatisticsRepositoryProtocol
    let quoteRepository: any QuoteRepositoryProtocol
    let calendarRepository: any CalendarRepositoryProtocol
    let bookmarkRepository: any BookmarkRepositoryProtocol
    let pdfProgressRepository: any PDFProgressRepositoryProtocol
    let pdfService: any PDFServiceProtocol
    let notificationManager: any NotificationSchedulingProtocol
    let calendarSyncService: any CalendarSyncServiceProtocol

    private let appLifecycleService: any AppLifecycleServicing

    init() {
        let appState = AppState()

        self.appState = appState
        self.userPreferences = UserPreferences()
        self.modelContainer = ModelContainerFactory.makeContainer()
        self.navigationRouter = NavigationRouter()

        let context = modelContainer.mainContext
        semesterRepository = SemesterRepository(modelContext: context)
        courseRepository = CourseRepository(modelContext: context)
        lectureRepository = LectureRepository(modelContext: context)
        assignmentRepository = AssignmentRepository(modelContext: context)
        readingRepository = ReadingRepository(modelContext: context)
        resourceRepository = ResourceRepository(modelContext: context)
        flashcardRepository = FlashcardRepository(modelContext: context)
        activeRecallRepository = ActiveRecallRepository(modelContext: context)
        noteRepository = NoteRepository(modelContext: context)
        studySessionRepository = StudySessionRepository(modelContext: context)
        statisticsRepository = StatisticsRepository(modelContext: context)
        quoteRepository = QuoteRepository(modelContext: context)
        calendarRepository = CalendarRepository(modelContext: context)
        bookmarkRepository = BookmarkRepository(modelContext: context)
        pdfProgressRepository = PDFProgressRepository(modelContext: context)
        pdfService = PDFService()
        notificationManager = NotificationManager()
        calendarSyncService = CalendarSyncService()

        appLifecycleService = AppLifecycleService(appState: appState, modelContainer: modelContainer)

        if let activeSemester = try? semesterRepository.fetchActive() {
            appState.update(activeSemester: activeSemester)
        }

        Self.seedQuotesIfNeeded(quoteRepository)
        Self.seedExtraTestDataIfNeeded(
            semesterRepository: semesterRepository,
            courseRepository: courseRepository,
            lectureRepository: lectureRepository
        )
    }

    // TEMPORARY — manual test-data seeding requested for this testing pass.
    // Adds two past semesters (one fully graded, one with a still-ungraded
    // course) plus a new course in the active semester with a genuinely
    // mixed past-graded/past-ungraded/future-scheduled assessment state, so
    // GPA/weight-validation/reflection-popup behavior all have real data to
    // exercise. Gated by a one-time UserDefaults flag so it never
    // duplicates — additive alongside whatever's already there, nothing
    // existing is touched. Remove this whole method (and its call above)
    // once testing is done; it should not ship.
    private static func seedExtraTestDataIfNeeded(
        semesterRepository: any SemesterRepositoryProtocol,
        courseRepository: any CourseRepositoryProtocol,
        lectureRepository: any LectureRepositoryProtocol
    ) {
        let key = "hasSeededExtraTestDataV1"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        UserDefaults.standard.set(true, forKey: key)

        let calendar = Calendar.current
        func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 9, _ minute: Int = 0) -> Date {
            calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)) ?? .now
        }

        func makeCourse(_ name: String, _ code: String, _ color: String, _ credits: Int, _ finalGrade: String?, _ semester: Semester) -> Course {
            let course = Course(name: name, courseCode: code, courseColor: color, credits: credits, finalLetterGrade: finalGrade)
            course.semester = semester
            try? courseRepository.create(course)
            return course
        }

        func makeLecture(_ title: String, _ topic: String, _ lectureDate: Date, _ course: Course) {
            let lecture = Lecture(
                title: title,
                topic: topic,
                date: lectureDate,
                startTime: lectureDate,
                endTime: calendar.date(byAdding: .hour, value: 1, to: lectureDate) ?? lectureDate
            )
            lecture.course = course
            try? lectureRepository.create(lecture)
        }

        func makeAssessment(_ title: String, _ kind: AssessmentKind, _ assessDate: Date, _ weight: Double, _ score: Double?, _ maxScore: Double, _ course: Course) {
            let assessment = Assessment(title: title, kind: kind, date: assessDate, weight: weight, score: score, maximumScore: maxScore)
            try? courseRepository.createAssessment(assessment, for: course)
        }

        // Spring 2025 — fully graded past semester (tests Cumulative GPA).
        let spring2025 = Semester(name: "Spring 2025", startDate: date(2025, 1, 6), endDate: date(2025, 5, 9), color: "green")
        try? semesterRepository.create(spring2025)

        let dataStructures = makeCourse("Data Structures", "CS201", "blue", 4, "A-", spring2025)
        makeLecture("Arrays & Linked Lists", "Intro", date(2025, 1, 13, 10), dataStructures)
        makeLecture("Trees & Graphs", "Traversal", date(2025, 2, 10, 10), dataStructures)
        makeLecture("Hash Tables", "Collision Handling", date(2025, 3, 3, 10), dataStructures)
        makeAssessment("Quiz 1", .quiz, date(2025, 2, 3, 10), 15, 18, 20, dataStructures)
        makeAssessment("Quiz 2", .quiz, date(2025, 3, 10, 10), 15, 16, 20, dataStructures)
        makeAssessment("Final Exam", .exam, date(2025, 5, 5, 14), 70, 82, 100, dataStructures)

        let linearAlgebra = makeCourse("Linear Algebra", "MATH204", "purple", 3, "B+", spring2025)
        makeLecture("Vector Spaces", "Basis & Dimension", date(2025, 1, 14, 9), linearAlgebra)
        makeLecture("Eigenvalues", "Diagonalization", date(2025, 3, 4, 9), linearAlgebra)
        makeAssessment("Midterm", .exam, date(2025, 3, 11, 9), 40, 75, 100, linearAlgebra)
        makeAssessment("Final Exam", .exam, date(2025, 5, 6, 9), 60, 80, 100, linearAlgebra)

        // Fall 2025 — one fully graded course, one course whose final grade
        // is still unset (tests the "semester not fully graded" state).
        let fall2025 = Semester(name: "Fall 2025", startDate: date(2025, 8, 11), endDate: date(2025, 12, 12), color: "orange")
        try? semesterRepository.create(fall2025)

        let algorithms = makeCourse("Algorithms", "CS301", "green", 4, "A", fall2025)
        makeLecture("Divide & Conquer", "Merge Sort", date(2025, 8, 18, 10), algorithms)
        makeLecture("Dynamic Programming", "Knapsack", date(2025, 10, 6, 10), algorithms)
        makeAssessment("Quiz 1", .quiz, date(2025, 9, 8, 10), 20, 19, 20, algorithms)
        makeAssessment("Final Exam", .exam, date(2025, 12, 5, 14), 80, 90, 100, algorithms)

        let databaseSystems = makeCourse("Database Systems", "CS305", "red", 3, nil, fall2025)
        makeLecture("Relational Model", "Normalization", date(2025, 8, 19, 13), databaseSystems)
        makeLecture("Query Optimization", "Indexing", date(2025, 10, 7, 13), databaseSystems)
        makeAssessment("Quiz 1", .quiz, date(2025, 9, 9, 13), 30, 22, 30, databaseSystems)
        makeAssessment("Final Exam", .exam, date(2025, 12, 6, 13), 40, nil, 100, databaseSystems)

        // Active semester — a new course with a genuinely mixed state: one
        // past+graded assessment, one past+ungraded assessment (triggers
        // the post-assessment reflection popup), one future assessment
        // (excluded from Current Grade, leaves weight unassigned).
        if let activeSemester = try? semesterRepository.fetchActive() {
            let operatingSystems = makeCourse("Operating Systems", "CS401", "brown", 3, nil, activeSemester)
            makeLecture("Processes & Threads", "Scheduling", date(2026, 7, 21, 10), operatingSystems)
            makeLecture("Memory Management", "Paging", date(2026, 8, 4, 10), operatingSystems)
            makeLecture("File Systems", "Journaling", date(2026, 8, 18, 10), operatingSystems)
            makeAssessment("Quiz 1", .quiz, date(2026, 7, 20, 10), 20, 17, 20, operatingSystems)
            makeAssessment("Quiz 2", .quiz, date(2026, 8, 1, 10), 20, nil, 20, operatingSystems)
            makeAssessment("Final Exam", .exam, date(2026, 12, 10, 14), 40, nil, 100, operatingSystems)
        }
    }

    /// `Quote`/`QuoteRepository` have existed since Phase 2 with no writer
    /// anywhere (confirmed by a full-project search) — dormant scaffolding,
    /// same shape as `StudySession` before Phase 4.3 and `ActiveRecallQuestion`'s
    /// SM-2 fields before Phase 4.4. Home's Study Overview card (which
    /// originally shipped with its own hardcoded quote list before this
    /// fix) is the first real consumer.
    ///
    /// Dedups by text rather than gating on "table is empty" — the starter
    /// list has grown since the first seed, and a purely "only if empty"
    /// check would never top up an install that already seeded the
    /// original 10. Runs every launch, but the fetch+compare is cheap and
    /// never touches or duplicates anything a user might add later.
    private static func seedQuotesIfNeeded(_ quoteRepository: any QuoteRepositoryProtocol) {
        let existingTexts = Set((try? quoteRepository.fetchAll())?.map(\.text) ?? [])

        let starterQuotes = [
            "Small steps every day add up to big results.",
            "The expert in anything was once a beginner.",
            "Review today so tomorrow is easier.",
            "Consistency beats intensity.",
            "Progress, not perfection.",
            "A little bit of review keeps a lot of forgetting away.",
            "You don't have to be great to start, but you have to start to be great.",
            "Your future self is built by what you do today.",
            "Well begun is half done.",
            "Slow and steady wins the race.",
            "Discipline is just remembering what you want.",
            "Every page you read is one you don't have to read again tomorrow.",
            "The hardest part is opening the book — you've already done that.",
            "Confusion is the first step toward understanding.",
            "You're not behind. You're exactly where your effort put you.",
            "A messy first draft beats a perfect blank page.",
            "Today's ten minutes is tomorrow's head start.",
            "Nobody remembers the day you started. They remember the day you finished.",
            "Understanding beats memorizing, every time.",
            "The notes you take today are a letter to your tired future self.",
            "One more flashcard won't hurt. Neither will one more rep.",
            "Good habits are just decisions you don't have to make twice.",
            "Rest is part of the plan, not a break from it.",
            "You don't need motivation. You need a next step.",
            "The syllabus doesn't know how hard this week has been. Keep going anyway.",
            "Clarity comes from doing, not from thinking about doing.",
            "It's not about finding time. It's about protecting it.",
            "Every expert's notes were once someone's first draft.",
            "A question you're brave enough to ask is half-answered already.",
            "You survived every hard day so far. That's a perfect record.",
            "Boring, consistent effort quietly wins.",
            "The exam doesn't test what you know. It tests what you practiced.",
            "Struggling with it means you're actually learning it.",
            "Momentum is built, not found.",
            "Your only competition is who you were yesterday.",
            "A short study session beats a long procrastination session.",
            "Some days you build the mountain. Some days you just climb it.",
            "The work you avoid grows heavier. The work you start gets lighter.",
            "You don't have to feel ready. You just have to begin.",
            "Understanding one thing well beats skimming ten things badly.",
            "Tired and showing up still counts.",
            "What feels impossible today is routine in a month.",
            "Your notes are a gift to the version of you who forgot.",
            "Done is better than perfect, especially at 11pm.",
            "The material doesn't care how you feel about it. Neither should you.",
            "Curiosity is the easiest way to make studying not feel like studying.",
            "Every review session is a deposit in a bank you'll withdraw from during exams.",
            "You are allowed to go slow, as long as you don't stop.",
            "The best time to review was yesterday. The second best time is now.",
            "A small win today is still a win.",
            "Learning is a loop, not a straight line — go back, that's normal.",
            "You're not stuck. You're just between two ideas that haven't met yet.",
            "What you practice in private shows up in public.",
            "Effort compounds quietly until, suddenly, it doesn't.",
            "The blank page is temporary. Your effort isn't.",
            "Nobody becomes disciplined overnight. They just start before they feel like it.",
            "Growth feels like confusion while it's happening.",
            "Study like the person you're becoming, not the person you were yesterday.",
            "A single focused hour beats three distracted ones.",
            "You don't need a perfect plan. You need a next step and five minutes.",
            "Some lessons only make sense the second time you meet them.",
            "The goal isn't to feel motivated. It's to build a habit that doesn't need it.",
            "Today's review is tomorrow's confidence.",
            "You are one honest study session away from feeling better about this.",
            "Doubt is loud, but it's not in charge.",
            "Every subject felt impossible before it felt easy.",
            "Progress hides in the sessions that felt like nothing happened.",
            "The version of you who finishes this started exactly where you are now.",
            "Consistency is a quiet kind of confidence.",
            "You learn a little by reading. You learn a lot by explaining it back.",
            "The best study plan is the one you'll actually follow.",
            "Give the hard subject your best hour, not your last one.",
            "A finished imperfect summary beats an unfinished perfect one.",
            "Your attention is the most valuable thing you own today. Spend it on purpose.",
            "You've already survived 100% of your hardest study days.",
            "Trust the process on the days you can't trust the results.",
            "The subject that scares you the most usually needs you the least time to start liking.",
            "Small, boring, repeated actions build big, exciting results.",
            "Every flashcard flipped is a tiny act of trust in your future self.",
            "You don't have to love the material to respect the process.",
            "What gets scheduled gets studied.",
            "The comeback is always bigger than the setback, if you keep showing up.",
            "One clear page of notes beats ten cluttered ones.",
            "Today you only have to be a little better than yesterday.",
            "The habit matters more than the mood.",
            "Learning sticks when you struggle for it a little.",
            "A tired brain that shows up still beats a sharp brain that doesn't.",
            "You're allowed to rest. You're just not allowed to quit.",
            "The work is the reward — the grade is just proof.",
            "Every course feels long in the middle. That's exactly where you are.",
            "Ask the question. The people around you probably have it too.",
            "You don't rise to the level of your goals, you fall to the level of your systems.",
            "A five-minute start has ended a lot of long procrastination streaks.",
            "The best revision is the one that makes you say it out loud.",
            "Study smarter today so tonight's you can rest easier.",
            "Not knowing yet is not the same as never knowing."
        ]

        for text in starterQuotes where !existingTexts.contains(text) {
            try? quoteRepository.create(Quote(text: text))
        }
    }

    func handle(scenePhase: ScenePhase) {
        appLifecycleService.handle(scenePhase: scenePhase)
    }
}
