import Foundation

@MainActor
@Observable
final class ActiveRecallViewModel {
    private let lecture: Lecture
    private let activeRecallRepository: any ActiveRecallRepositoryProtocol

    private(set) var questions: [ActiveRecallQuestion] = []
    private(set) var loadError: StudyHubError?

    init(lecture: Lecture, activeRecallRepository: any ActiveRecallRepositoryProtocol) {
        self.lecture = lecture
        self.activeRecallRepository = activeRecallRepository
    }

    func loadQuestions() {
        do {
            questions = try activeRecallRepository.fetch(forLecture: lecture)
            loadError = nil
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.fetchFailed(underlying: error)
        }
    }

    func createQuestion(question: String, answer: String, questionType: QuestionType) {
        let recallQuestion = ActiveRecallQuestion(
            question: question,
            answer: answer,
            questionType: questionType
        )
        recallQuestion.lecture = lecture

        do {
            try activeRecallRepository.create(recallQuestion)
            loadQuestions()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func updateQuestion(
        _ recallQuestion: ActiveRecallQuestion,
        question: String,
        answer: String,
        questionType: QuestionType
    ) {
        recallQuestion.question = question
        recallQuestion.answer = answer
        recallQuestion.questionType = questionType
        recallQuestion.updatedAt = Date.now

        do {
            try activeRecallRepository.save()
            loadQuestions()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.saveFailed(underlying: error)
        }
    }

    func deleteQuestion(_ recallQuestion: ActiveRecallQuestion) {
        do {
            try activeRecallRepository.delete(recallQuestion)
            loadQuestions()
        } catch let error as StudyHubError {
            loadError = error
        } catch {
            loadError = PersistenceError.deleteFailed(underlying: error)
        }
    }
}

extension QuestionType {
    var label: String {
        switch self {
        case .questionAnswer: return "Question Answer"
        case .fillBlank: return "Fill Blank"
        case .definition: return "Definition"
        case .diagram: return "Diagram"
        case .image: return "Image"
        case .essay: return "Essay"
        }
    }
}
