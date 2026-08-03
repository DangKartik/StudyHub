import Foundation

// MARK: - Result structs

struct StudyTimeSummary {
    var todayMinutes: Int = 0
    var weekMinutes: Int = 0
    var monthMinutes: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0

    /// Shared by `AnalyticsViewModel` and `HomeViewModel` — pulled out so
    /// Home's "Study Statistics" section shows the exact same numbers
    /// Analytics does, computed once instead of twice.
    static func compute(sessions: [StudySession], calendar: Calendar, now: Date = .now) -> StudyTimeSummary {
        let todaySeconds = sessions
            .filter { calendar.isDateInToday($0.startTime) }
            .reduce(0.0) { $0 + $1.duration }

        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let weekSeconds = sessions
            .filter { $0.startTime >= startOfWeek }
            .reduce(0.0) { $0 + $1.duration }

        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        let monthSeconds = sessions
            .filter { $0.startTime >= startOfMonth }
            .reduce(0.0) { $0 + $1.duration }

        let studyDays = Set(sessions.map { calendar.startOfDay(for: $0.startTime) })
        let current = currentStreakDays(studyDays: studyDays, calendar: calendar, now: now).count

        var longest = 0
        var running = 0
        var previousDay: Date?
        for day in studyDays.sorted() {
            if let previousDay, calendar.date(byAdding: .day, value: 1, to: previousDay) == day {
                running += 1
            } else {
                running = 1
            }
            longest = max(longest, running)
            previousDay = day
        }

        return StudyTimeSummary(
            todayMinutes: Int(todaySeconds / 60),
            weekMinutes: Int(weekSeconds / 60),
            monthMinutes: Int(monthSeconds / 60),
            currentStreak: current,
            longestStreak: longest
        )
    }

    /// The specific calendar days making up the current streak (not just
    /// its count) — used by the Analytics calendar to highlight which
    /// exact cells are part of it. Shares its walk-backward logic with
    /// `compute(_:)`'s `currentStreak`, so the two can never disagree.
    static func currentStreakDays(sessions: [StudySession], calendar: Calendar, now: Date = .now) -> Set<Date> {
        let studyDays = Set(sessions.map { calendar.startOfDay(for: $0.startTime) })
        return currentStreakDays(studyDays: studyDays, calendar: calendar, now: now)
    }

    private static func currentStreakDays(studyDays: Set<Date>, calendar: Calendar, now: Date) -> Set<Date> {
        var days: Set<Date> = []
        var cursor = calendar.startOfDay(for: now)
        if !studyDays.contains(cursor) {
            // Today has no session yet, but the day isn't over — the streak
            // isn't broken until a day passes with nothing logged, so start
            // counting from yesterday instead of zeroing out immediately.
            cursor = calendar.date(byAdding: .day, value: -1, to: cursor) ?? cursor
        }
        while studyDays.contains(cursor) {
            days.insert(cursor)
            cursor = calendar.date(byAdding: .day, value: -1, to: cursor) ?? cursor
        }
        return days
    }
}

struct ReadingAnalytics {
    var pagesRead: Int = 0
    var booksCompleted: Int = 0
    /// `nil` when there isn't enough data (no Study Session ever recorded
    /// any pages read) to estimate a speed at all.
    var averageReadingSpeedPagesPerHour: Double?
}

/// Flashcard stats are deliberately snapshot-based, not a true longitudinal
/// history — the schema only stores each card's *current* rating/schedule
/// (Phase 4.4), not a log of every past review. See
/// `AnalyticsViewModel.computeFlashcardAnalytics` for why "retention
/// estimate" is computed this way rather than adding a review-log model.
struct FlashcardAnalytics {
    var cardsReviewed: Int = 0
    var cardsDue: Int = 0
    var averageEaseFactor: Double?
    var averageIntervalDays: Double?
    var retentionEstimatePercent: Double?
}

/// Same snapshot-based caveat as `FlashcardAnalytics` — "success rate" and
/// "average confidence" both derive from each question's *current* rating,
/// not a full history of every past answer.
struct ActiveRecallAnalytics {
    var questionsAnswered: Int = 0
    var successRatePercent: Double?
    var averageConfidencePercent: Double?
}

struct SessionAnalytics {
    var averageSessionMinutes: Double?
    var longestSessionMinutes: Double?
    var totalPomodoros: Int = 0
    var mostStudiedCourseName: String?
}

struct DailyDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let minutes: Double
}

struct WeeklyDataPoint: Identifiable {
    let id = UUID()
    let weekStart: Date
    let minutes: Double
}

struct CourseDistributionPoint: Identifiable {
    let id = UUID()
    let courseName: String
    let minutes: Double
}

struct ReviewHistoryPoint: Identifiable {
    let id = UUID()
    let date: Date
    let flashcardReviews: Int
    let questionReviews: Int
}

struct ReadingProgressPoint: Identifiable {
    let id = UUID()
    let courseName: String
    let percent: Double
}

/// Every number here uses `Course.credits` as the weight — a course with no
/// credits set can't contribute to either GPA, same "excluded, not zero"
/// rule `GradeCalculator` already uses for weight. Both are built purely
/// from real `Course.finalLetterGrade` values — no estimating a grade for
/// an in-progress course, which only ever produced a guess dressed up as a
/// number. An in-progress course's live standing still shows as a plain
/// percentage on its own Grades page.
struct GPASummary {
    var semesterName: String?
    var semesterGPA: Double?
    var semesterCredits: Int = 0
    var cumulativeGPA: Double?
    var cumulativeCredits: Int = 0
}

/// One row of the per-semester GPA breakdown (`GPADetailView`) — `gpa` is
/// `nil` under the exact same "not every credited course has a Final
/// Letter Grade yet" rule `GPASummary.semesterGPA` uses, just applied to
/// every semester rather than only the active one.
struct SemesterGPARow: Identifiable {
    let id: UUID
    let name: String
    let gpa: Double?
    let credits: Int
    let isActive: Bool
}

/// One cell in the real calendar-month grid (Study Session Analytics'
/// "daily study heatmap", requirement 5) — `date`/`dayNumber` are `nil` for
/// the leading/trailing filler cells that pad the grid out to full weeks
/// before day 1 and after the month's last day.
struct CalendarDayCell: Identifiable {
    let id = UUID()
    let date: Date?
    let dayNumber: Int?
    let minutes: Double
    let isToday: Bool
    let isInCurrentStreak: Bool

    init(date: Date? = nil, dayNumber: Int? = nil, minutes: Double = 0, isToday: Bool = false, isInCurrentStreak: Bool = false) {
        self.date = date
        self.dayNumber = dayNumber
        self.minutes = minutes
        self.isToday = isToday
        self.isInCurrentStreak = isInCurrentStreak
    }
}

/// Read-only analytics (Phase 4.5) — every number here is computed fresh
/// from existing repositories each time `loadAnalytics()` runs; nothing is
/// persisted or duplicated. `StatisticsSnapshot`/`StatisticsRepository`
/// (dormant scaffolding since Phase 2, confirmed unused by any writer) is
/// deliberately NOT used, for the same reason DECISION-037 ignored
/// `StudySession`'s own dormant fields before reshaping it: dormant,
/// never-populated fields aren't a data source, they're just unused schema.
@MainActor
@Observable
final class AnalyticsViewModel {
    private let appState: AppState
    private let courseRepository: any CourseRepositoryProtocol
    private let semesterRepository: any SemesterRepositoryProtocol
    private let readingRepository: any ReadingRepositoryProtocol
    private let pdfProgressRepository: any PDFProgressRepositoryProtocol
    private let flashcardRepository: any FlashcardRepositoryProtocol
    private let activeRecallRepository: any ActiveRecallRepositoryProtocol
    private let studySessionRepository: any StudySessionRepositoryProtocol
    private let userPreferences: UserPreferences

    private(set) var loadError: StudyHubError?
    private(set) var isLoading = true

    private(set) var studyTimeSummary = StudyTimeSummary()
    private(set) var readingAnalytics = ReadingAnalytics()
    private(set) var flashcardAnalytics = FlashcardAnalytics()
    private(set) var activeRecallAnalytics = ActiveRecallAnalytics()
    private(set) var sessionAnalytics = SessionAnalytics()
    private(set) var readingProgressByCourse: [ReadingProgressPoint] = []
    private(set) var gpaSummary = GPASummary()
    private(set) var semesterGPABreakdown: [SemesterGPARow] = []

    private(set) var dailyStudyTimeChart: [DailyDataPoint] = []
    private(set) var weeklyTrendChart: [WeeklyDataPoint] = []
    private(set) var courseDistributionChart: [CourseDistributionPoint] = []
    private(set) var reviewHistoryChart: [ReviewHistoryPoint] = []
    /// Weekday names in an order matching `calendarDays`'s implicit
    /// Mon-first-or-Sun-first layout (index 0 = whichever day
    /// `UserPreferences.weekStartsOnMonday` currently calls first).
    private(set) var weekdayLabels: [String] = []

    private(set) var displayedMonth: Date = .now
    private(set) var calendarDays: [CalendarDayCell] = []
    private(set) var monthStudyMinutes: Int = 0
    /// Retained (not just used transiently in `loadAnalytics()`) so month
    /// navigation can recompute the calendar grid in-memory without a
    /// repository round-trip.
    private var allSessions: [StudySession] = []

    /// How far back the daily/weekly charts look — a fixed window, not a
    /// user-adjustable range, to keep this phase's scope additive.
    private static let dailyChartDays = 30
    private static let weeklyTrendWeeks = 12

    init(
        appState: AppState,
        courseRepository: any CourseRepositoryProtocol,
        semesterRepository: any SemesterRepositoryProtocol,
        readingRepository: any ReadingRepositoryProtocol,
        pdfProgressRepository: any PDFProgressRepositoryProtocol,
        flashcardRepository: any FlashcardRepositoryProtocol,
        activeRecallRepository: any ActiveRecallRepositoryProtocol,
        studySessionRepository: any StudySessionRepositoryProtocol,
        userPreferences: UserPreferences
    ) {
        self.appState = appState
        self.courseRepository = courseRepository
        self.semesterRepository = semesterRepository
        self.readingRepository = readingRepository
        self.pdfProgressRepository = pdfProgressRepository
        self.flashcardRepository = flashcardRepository
        self.activeRecallRepository = activeRecallRepository
        self.studySessionRepository = studySessionRepository
        self.userPreferences = userPreferences
    }

    func loadAnalytics() {
        defer { isLoading = false }
        do {
            let courses = try courseRepository.fetchAll()
            let sessions = try studySessionRepository.fetchAll()
            let flashcards = try flashcardRepository.fetchAll()
            let questions = try activeRecallRepository.fetchAll()
            let readings = try readingRepository.fetchAll()

            allSessions = sessions

            computeStudyTimeSummary(sessions: sessions)
            computeReadingAnalytics(readings: readings, courses: courses, sessions: sessions)
            computeFlashcardAnalytics(flashcards)
            computeActiveRecallAnalytics(questions)
            computeSessionAnalytics(sessions: sessions, courses: courses)
            computeCharts(sessions: sessions, courses: courses)
            recomputeCalendarMonth()
            computeGPA(courses: courses)

            loadError = nil
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.fetchFailed(underlying: error)
        }
    }

    // MARK: - Section 1: Study time + streaks

    private func computeStudyTimeSummary(sessions: [StudySession]) {
        studyTimeSummary = StudyTimeSummary.compute(sessions: sessions, calendar: userPreferences.calendar)
    }

    // MARK: - Section 2: Reading

    /// Joins each Reading to its PDF attachment's `PDFProgress` (looked up
    /// by `sourceURL`, the only key `PDFProgressRepository` supports —
    /// mirrors `StudySessionViewModel.currentTotalPagesRead()`'s exact join
    /// pattern). "Average reading speed" is a necessary approximation:
    /// neither `Reading` nor `PDFProgress` tracks time spent reading, so
    /// this uses Study Sessions that logged any pages read as the only
    /// actual time signal available — total pages read across those
    /// sessions divided by their total duration. It's blended with whatever
    /// else happened in the same session (Notes, Active Recall, etc.), not
    /// pure reading time, since nothing tracks time per-tab.
    private func computeReadingAnalytics(readings: [Reading], courses: [Course], sessions: [StudySession]) {
        var totalPagesRead = 0
        var booksCompleted = 0
        var progressByCourseID: [UUID: (readPages: Int, totalPages: Int)] = [:]

        for reading in readings {
            guard let pdfAttachment = reading.attachments.first(where: { AttachmentKind(rawValue: $0.type) == .pdf }),
                  let progress = try? pdfProgressRepository.fetch(sourceURL: pdfAttachment.url) else { continue }

            let pagesRead = progress.highestPageIndex + 1
            totalPagesRead += pagesRead

            if progress.pageCount > 0 && pagesRead >= progress.pageCount {
                booksCompleted += 1
            }

            if let courseID = reading.course?.id, progress.pageCount > 0 {
                var entry = progressByCourseID[courseID] ?? (0, 0)
                entry.readPages += pagesRead
                entry.totalPages += progress.pageCount
                progressByCourseID[courseID] = entry
            }
        }

        readingProgressByCourse = courses.compactMap { course in
            guard let entry = progressByCourseID[course.id], entry.totalPages > 0 else { return nil }
            let percent = Double(entry.readPages) / Double(entry.totalPages) * 100
            return ReadingProgressPoint(courseName: courseLabel(course), percent: min(100, percent))
        }.sorted { $0.percent > $1.percent }

        // Neither Reading nor PDFProgress tracks time spent reading, so this
        // uses Study Sessions that logged any pages read as the only actual
        // time signal available — see the type's doc comment for the caveat.
        let sessionsWithReading = sessions.filter { $0.pagesReadCount > 0 }
        let readingSpeed: Double?
        if sessionsWithReading.isEmpty {
            readingSpeed = nil
        } else {
            let totalPagesInSessions = sessionsWithReading.reduce(0) { $0 + $1.pagesReadCount }
            let totalHours = sessionsWithReading.reduce(0.0) { $0 + $1.duration } / 3600
            readingSpeed = totalHours > 0 ? Double(totalPagesInSessions) / totalHours : nil
        }

        readingAnalytics = ReadingAnalytics(
            pagesRead: totalPagesRead,
            booksCompleted: booksCompleted,
            averageReadingSpeedPagesPerHour: readingSpeed
        )
    }

    // MARK: - Section 3: Flashcards

    /// "Retention estimate" here means "% of already-reviewed cards whose
    /// *current* rating is Good/Easy" — a point-in-time snapshot, not a
    /// true historical retention rate (that would need a per-review log,
    /// which the schema deliberately doesn't have; see the type's doc
    /// comment).
    private func computeFlashcardAnalytics(_ flashcards: [Flashcard]) {
        let reviewed = flashcards.filter { $0.reviewCount > 0 }
        let due = flashcards.filter { DueQueueSection.classify(nextReviewDate: $0.nextReviewDate).isDueNow }

        let averageEase = reviewed.isEmpty ? nil : reviewed.reduce(0.0) { $0 + $1.easeFactor } / Double(reviewed.count)
        let averageInterval = reviewed.isEmpty ? nil : reviewed.reduce(0.0) { $0 + $1.interval } / Double(reviewed.count)

        let retention: Double?
        if reviewed.isEmpty {
            retention = nil
        } else {
            let recalled = reviewed.filter { $0.difficulty == FlashcardRating.good.rawValue || $0.difficulty == FlashcardRating.easy.rawValue }
            retention = Double(recalled.count) / Double(reviewed.count) * 100
        }

        flashcardAnalytics = FlashcardAnalytics(
            cardsReviewed: reviewed.count,
            cardsDue: due.count,
            averageEaseFactor: averageEase,
            averageIntervalDays: averageInterval,
            retentionEstimatePercent: retention
        )
    }

    // MARK: - Section 4: Active Recall

    /// "Average confidence" maps each rating to a 0-100% scale (Again=0%,
    /// Hard=33%, Good=66%, Easy=100%) and averages that across already-
    /// answered questions — a derived reading of the existing `difficulty`
    /// field, not a separately-tracked "confidence" value (no such field
    /// exists). Same snapshot caveat as Flashcard's retention estimate.
    private func computeActiveRecallAnalytics(_ questions: [ActiveRecallQuestion]) {
        let answered = questions.filter { $0.reviewCount > 0 }

        let successRate: Double?
        let confidence: Double?
        if answered.isEmpty {
            successRate = nil
            confidence = nil
        } else {
            let successful = answered.filter { $0.difficulty == RecallRating.good.rawValue || $0.difficulty == RecallRating.easy.rawValue }
            successRate = Double(successful.count) / Double(answered.count) * 100

            let confidenceScores: [Double] = answered.compactMap { question in
                switch RecallRating(rawValue: question.difficulty) {
                case .again: return 0
                case .hard: return 33
                case .good: return 66
                case .easy: return 100
                case nil: return nil
                }
            }
            confidence = confidenceScores.isEmpty ? nil : confidenceScores.reduce(0, +) / Double(confidenceScores.count)
        }

        activeRecallAnalytics = ActiveRecallAnalytics(
            questionsAnswered: answered.count,
            successRatePercent: successRate,
            averageConfidencePercent: confidence
        )
    }

    // MARK: - Section 5: Study Sessions

    private func computeSessionAnalytics(sessions: [StudySession], courses: [Course]) {
        let completed = sessions.filter { $0.duration > 0 }

        let averageMinutes = completed.isEmpty ? nil : (completed.reduce(0.0) { $0 + $1.duration } / Double(completed.count)) / 60
        let longestMinutes = completed.map(\.duration).max().map { $0 / 60 }
        let totalPomodoros = sessions.reduce(0) { $0 + $1.completedPomodoros }

        var durationByCourseID: [UUID: Double] = [:]
        for session in sessions {
            guard let courseID = session.course?.id else { continue }
            durationByCourseID[courseID, default: 0] += session.duration
        }
        let mostStudied = courses
            .compactMap { course in durationByCourseID[course.id].map { (course, $0) } }
            .max { $0.1 < $1.1 }

        sessionAnalytics = SessionAnalytics(
            averageSessionMinutes: averageMinutes,
            longestSessionMinutes: longestMinutes,
            totalPomodoros: totalPomodoros,
            mostStudiedCourseName: mostStudied.map { courseLabel($0.0) }
        )
    }

    // MARK: - Section 6: Charts

    private func computeCharts(sessions: [StudySession], courses: [Course]) {
        let calendar = userPreferences.calendar
        let today = calendar.startOfDay(for: .now)

        // Daily study time (last `dailyChartDays` days).
        var minutesByDay: [Date: Double] = [:]
        var flashcardReviewsByDay: [Date: Int] = [:]
        var questionReviewsByDay: [Date: Int] = [:]
        for session in sessions {
            let day = calendar.startOfDay(for: session.startTime)
            minutesByDay[day, default: 0] += session.duration / 60
            flashcardReviewsByDay[day, default: 0] += session.flashcardsReviewedCount
            questionReviewsByDay[day, default: 0] += session.questionsAnsweredCount
        }

        var daily: [DailyDataPoint] = []
        var review: [ReviewHistoryPoint] = []
        for offset in stride(from: Self.dailyChartDays - 1, through: 0, by: -1) {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            daily.append(DailyDataPoint(date: day, minutes: minutesByDay[day] ?? 0))
            review.append(ReviewHistoryPoint(
                date: day,
                flashcardReviews: flashcardReviewsByDay[day] ?? 0,
                questionReviews: questionReviewsByDay[day] ?? 0
            ))
        }
        dailyStudyTimeChart = daily
        reviewHistoryChart = review

        // Weekly trend (last 12 weeks, keyed by week start).
        var minutesByWeek: [Date: Double] = [:]
        for session in sessions {
            guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: session.startTime)?.start else { continue }
            minutesByWeek[weekStart, default: 0] += session.duration / 60
        }
        let thisWeekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        var weekly: [WeeklyDataPoint] = []
        for offset in stride(from: Self.weeklyTrendWeeks - 1, through: 0, by: -1) {
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -offset, to: thisWeekStart) else { continue }
            weekly.append(WeeklyDataPoint(weekStart: weekStart, minutes: minutesByWeek[weekStart] ?? 0))
        }
        weeklyTrendChart = weekly

        // Course distribution (total minutes per course, all-time).
        var minutesByCourseID: [UUID: Double] = [:]
        for session in sessions {
            guard let courseID = session.course?.id else { continue }
            minutesByCourseID[courseID, default: 0] += session.duration / 60
        }
        courseDistributionChart = courses
            .compactMap { course in minutesByCourseID[course.id].map { CourseDistributionPoint(courseName: courseLabel(course), minutes: $0) } }
            .filter { $0.minutes > 0 }
            .sorted { $0.minutes > $1.minutes }

        let symbols = calendar.shortWeekdaySymbols // always index 0 = Sunday, regardless of firstWeekday
        weekdayLabels = (0..<7).map { position in
            let rawWeekday = ((calendar.firstWeekday - 1 + position) % 7) + 1
            return symbols[rawWeekday - 1]
        }
    }

    // MARK: - GPA

    /// Semester GPA uses `appState.activeSemester` (the same "currently
    /// selected semester" concept the rest of the app already uses, e.g.
    /// Home's dashboard) — not every semester the courses happen to belong
    /// to. Projected spans every course regardless of semester.
    ///
    /// Both Semester and Cumulative are all-or-nothing for the active
    /// semester: a semester GPA only means something once every one of its
    /// (credited) courses has a real final grade — a partial average from
    /// just the courses graded so far would misrepresent it. Cumulative
    /// follows the same rule for the active semester specifically (it
    /// simply excludes it until it's fully graded); other, already-past
    /// semesters aren't gated this way since they're assumed complete.
    private func computeGPA(courses: [Course]) {
        let semesters = (try? semesterRepository.fetchAll()) ?? []
        let activeSemesterID = appState.activeSemester?.id

        var breakdown: [SemesterGPARow] = []
        var cumulativePoints = 0.0
        var cumulativeCredits = 0

        for semester in semesters.sorted(by: { $0.startDate > $1.startDate }) {
            let semesterCourses = courses.filter { $0.semester?.id == semester.id }
            let result = gatedGPA(for: semesterCourses)
            breakdown.append(SemesterGPARow(
                id: semester.id,
                name: semester.name,
                gpa: result.gpa,
                credits: result.totalCredits,
                isActive: semester.id == activeSemesterID
            ))
            // Cumulative only pools in semesters that are themselves fully
            // graded — a semester still in progress (including the active
            // one) doesn't contribute a partial number to it.
            if let gpa = result.gpa {
                cumulativePoints += gpa * Double(result.totalCredits)
                cumulativeCredits += result.totalCredits
            }
        }
        semesterGPABreakdown = breakdown

        let activeRow = breakdown.first { $0.isActive }

        gpaSummary = GPASummary(
            semesterName: appState.activeSemester?.name,
            semesterGPA: activeRow?.gpa,
            semesterCredits: activeRow?.credits ?? 0,
            cumulativeGPA: cumulativeCredits > 0 ? cumulativePoints / Double(cumulativeCredits) : nil,
            cumulativeCredits: cumulativeCredits
        )
    }

    /// A semester (or any group of courses) only produces a real GPA once
    /// every one of its credited courses has a Final Letter Grade set —
    /// see `GPASummary.semesterGPA`'s doc comment for why a partial
    /// average would be misleading.
    private func gatedGPA(for courses: [Course]) -> GPAResult {
        let credited = courses.filter { $0.credits > 0 }
        guard !credited.isEmpty, credited.allSatisfy({ $0.finalLetterGrade != nil }) else {
            return GPAResult(gpa: nil, totalCredits: 0)
        }
        return GPACalculator.gpa(for: courses)
    }

    // MARK: - Calendar month (Study Session heatmap, requirement 5)

    /// Rebuilds `calendarDays` for `displayedMonth` from the already-fetched
    /// `allSessions` — cheap, in-memory, so month navigation doesn't need a
    /// repository round-trip.
    private func recomputeCalendarMonth() {
        let calendar = userPreferences.calendar
        let now = Date.now
        let today = calendar.startOfDay(for: now)

        var minutesByDay: [Date: Double] = [:]
        for session in allSessions {
            let day = calendar.startOfDay(for: session.startTime)
            minutesByDay[day, default: 0] += session.duration / 60
        }

        let streakDays = StudyTimeSummary.currentStreakDays(sessions: allSessions, calendar: calendar, now: now)

        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
              let daysInMonth = calendar.range(of: .day, in: .month, for: displayedMonth)?.count else {
            calendarDays = []
            monthStudyMinutes = 0
            return
        }

        let firstOfMonth = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let leadingBlanks = ((firstWeekday - calendar.firstWeekday) + 7) % 7

        var cells: [CalendarDayCell] = Array(repeating: CalendarDayCell(), count: leadingBlanks)

        var monthTotal = 0.0
        for dayNumber in 1...daysInMonth {
            guard let date = calendar.date(byAdding: .day, value: dayNumber - 1, to: firstOfMonth) else { continue }
            let minutes = minutesByDay[date] ?? 0
            monthTotal += minutes
            cells.append(CalendarDayCell(
                date: date,
                dayNumber: dayNumber,
                minutes: minutes,
                isToday: date == today,
                isInCurrentStreak: streakDays.contains(date)
            ))
        }

        // Trailing filler so the grid always ends on a full week — purely
        // cosmetic, keeps the last row from looking cut off.
        let remainder = cells.count % 7
        if remainder != 0 {
            cells.append(contentsOf: Array(repeating: CalendarDayCell(), count: 7 - remainder))
        }

        calendarDays = cells
        monthStudyMinutes = Int(monthTotal)
    }

    func goToPreviousMonth() {
        displayedMonth = userPreferences.calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
        recomputeCalendarMonth()
    }

    func goToNextMonth() {
        displayedMonth = userPreferences.calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
        recomputeCalendarMonth()
    }

    func goToCurrentMonth() {
        displayedMonth = .now
        recomputeCalendarMonth()
    }

    private func courseLabel(_ course: Course) -> String {
        course.name.isEmpty ? course.courseCode : course.name
    }
}
