import Foundation

@MainActor
@Observable
final class GradesViewModel {
    private let course: Course
    private let courseRepository: any CourseRepositoryProtocol

    private(set) var gradeCategories: [GradeCategory] = []
    private(set) var quizzes: [Quiz] = []
    private(set) var exams: [Exam] = []
    private(set) var loadError: StudyHubError?

    init(course: Course, courseRepository: any CourseRepositoryProtocol) {
        self.course = course
        self.courseRepository = courseRepository
    }

    /// Weighted average over graded categories only. A category with no positive
    /// weight or no positive maximum score can't contribute a meaningful
    /// percentage, so it's excluded from both the sum and the weight total
    /// rather than counted as a zero (see DECISION-024).
    var currentGrade: Double? {
        let graded = gradeCategories.filter { $0.weight > 0 && $0.maximumScore > 0 }
        guard !graded.isEmpty else { return nil }

        let totalValidWeight = graded.reduce(0) { $0 + $1.weight }
        guard totalValidWeight > 0 else { return nil }

        let totalWeightedContribution = graded.reduce(0) { total, category in
            let categoryPercentage = category.earnedScore / category.maximumScore
            let weightedContribution = categoryPercentage * category.weight
            return total + weightedContribution
        }

        return (totalWeightedContribution / totalValidWeight) * 100
    }

    func loadGrades() {
        do {
            gradeCategories = try courseRepository.fetchGradeCategories(for: course)
            quizzes = try courseRepository.fetchQuizzes(for: course)
            exams = try courseRepository.fetchExams(for: course)
            loadError = nil
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.fetchFailed(underlying: error)
        }
    }

    // MARK: - Grade Categories

    func createGradeCategory(title: String, weight: Double, earnedScore: Double, maximumScore: Double) {
        let category = GradeCategory(
            title: title,
            weight: weight,
            earnedScore: earnedScore,
            maximumScore: maximumScore
        )

        do {
            try courseRepository.createGradeCategory(category, for: course)
            loadGrades()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func updateGradeCategory(
        _ category: GradeCategory,
        title: String,
        weight: Double,
        earnedScore: Double,
        maximumScore: Double
    ) {
        category.title = title
        category.weight = weight
        category.earnedScore = earnedScore
        category.maximumScore = maximumScore
        category.updatedAt = Date.now

        do {
            try courseRepository.save()
            loadGrades()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func deleteGradeCategory(_ category: GradeCategory) {
        do {
            try courseRepository.deleteGradeCategory(category)
            loadGrades()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.deleteFailed(underlying: error)
        }
    }

    // MARK: - Quizzes

    func createQuiz(title: String, date: Date, weight: Double, score: Double?, maximumScore: Double, notes: String) {
        let quiz = Quiz(
            title: title,
            date: date,
            weight: weight,
            score: score,
            maximumScore: maximumScore,
            notes: notes
        )

        do {
            try courseRepository.createQuiz(quiz, for: course)
            loadGrades()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func updateQuiz(
        _ quiz: Quiz,
        title: String,
        date: Date,
        weight: Double,
        score: Double?,
        maximumScore: Double,
        notes: String
    ) {
        quiz.title = title
        quiz.date = date
        quiz.weight = weight
        quiz.score = score
        quiz.maximumScore = maximumScore
        quiz.notes = notes
        quiz.updatedAt = Date.now

        do {
            try courseRepository.save()
            loadGrades()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func deleteQuiz(_ quiz: Quiz) {
        do {
            try courseRepository.deleteQuiz(quiz)
            loadGrades()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.deleteFailed(underlying: error)
        }
    }

    // MARK: - Exams

    func createExam(title: String, date: Date, location: String, weight: Double, duration: TimeInterval, notes: String) {
        let exam = Exam(
            title: title,
            date: date,
            location: location,
            weight: weight,
            duration: duration,
            notes: notes
        )

        do {
            try courseRepository.createExam(exam, for: course)
            loadGrades()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func updateExam(
        _ exam: Exam,
        title: String,
        date: Date,
        location: String,
        weight: Double,
        duration: TimeInterval,
        notes: String
    ) {
        exam.title = title
        exam.date = date
        exam.location = location
        exam.weight = weight
        exam.duration = duration
        exam.notes = notes
        exam.updatedAt = Date.now

        do {
            try courseRepository.save()
            loadGrades()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func deleteExam(_ exam: Exam) {
        do {
            try courseRepository.deleteExam(exam)
            loadGrades()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.deleteFailed(underlying: error)
        }
    }
}
