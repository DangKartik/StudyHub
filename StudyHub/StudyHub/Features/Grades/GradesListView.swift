import SwiftUI

struct GradesListView: View {
    @State private var viewModel: GradesViewModel
    @State private var activeSheet: GradeSheet?

    init(course: Course, courseRepository: any CourseRepositoryProtocol) {
        _viewModel = State(wrappedValue: GradesViewModel(
            course: course,
            courseRepository: courseRepository
        ))
    }

    var body: some View {
        Group {
            if viewModel.gradeCategories.isEmpty && viewModel.quizzes.isEmpty && viewModel.exams.isEmpty {
                StudyHubEmptyState(
                    icon: "chart.bar",
                    title: "No Grades Yet",
                    message: "Add grade categories, quizzes, and exams to track this course."
                )
            } else {
                list
            }
        }
        .navigationTitle("Grades")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("Add Grade Category", systemImage: "chart.pie") {
                        activeSheet = .createCategory
                    }
                    Button("Add Quiz", systemImage: "pencil.and.list.clipboard") {
                        activeSheet = .createQuiz
                    }
                    Button("Add Exam", systemImage: "graduationcap") {
                        activeSheet = .createExam
                    }
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .createCategory:
                GradeCategoryFormView(viewModel: viewModel, gradeCategory: nil)
            case .editCategory(let category):
                GradeCategoryFormView(viewModel: viewModel, gradeCategory: category)
            case .createQuiz:
                QuizFormView(viewModel: viewModel, quiz: nil)
            case .editQuiz(let quiz):
                QuizFormView(viewModel: viewModel, quiz: quiz)
            case .createExam:
                ExamFormView(viewModel: viewModel, exam: nil)
            case .editExam(let exam):
                ExamFormView(viewModel: viewModel, exam: exam)
            }
        }
        .onAppear {
            viewModel.loadGrades()
        }
    }

    private var list: some View {
        List {
            if let error = viewModel.loadError {
                Section {
                    Text(error.message)
                        .foregroundStyle(.red)
                }
            }

            Section {
                if let currentGrade = viewModel.currentGrade {
                    Text("\(currentGrade, specifier: "%.1f")%")
                        .font(.largeTitle.bold())
                } else {
                    Text("No Grade Yet")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Current Grade")
            }

            if !viewModel.gradeCategories.isEmpty {
                Section("Grade Categories") {
                    ForEach(viewModel.gradeCategories, id: \.id) { category in
                        GradeCategoryRowView(category: category)
                            .onTapGesture {
                                activeSheet = .editCategory(category)
                            }
                            .swipeActions(edge: .trailing) {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    viewModel.deleteGradeCategory(category)
                                }
                            }
                    }
                }
            }

            if !viewModel.quizzes.isEmpty {
                Section("Quizzes") {
                    ForEach(viewModel.quizzes, id: \.id) { quiz in
                        QuizRowView(quiz: quiz)
                            .onTapGesture {
                                activeSheet = .editQuiz(quiz)
                            }
                            .swipeActions(edge: .trailing) {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    viewModel.deleteQuiz(quiz)
                                }
                            }
                    }
                }
            }

            if !viewModel.exams.isEmpty {
                Section("Exams") {
                    ForEach(viewModel.exams, id: \.id) { exam in
                        ExamRowView(exam: exam)
                            .onTapGesture {
                                activeSheet = .editExam(exam)
                            }
                            .swipeActions(edge: .trailing) {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    viewModel.deleteExam(exam)
                                }
                            }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

private enum GradeSheet: Identifiable {
    case createCategory
    case editCategory(GradeCategory)
    case createQuiz
    case editQuiz(Quiz)
    case createExam
    case editExam(Exam)

    var id: String {
        switch self {
        case .createCategory: return "createCategory"
        case .editCategory(let category): return category.id.uuidString
        case .createQuiz: return "createQuiz"
        case .editQuiz(let quiz): return quiz.id.uuidString
        case .createExam: return "createExam"
        case .editExam(let exam): return exam.id.uuidString
        }
    }
}

private struct GradeCategoryRowView: View {
    let category: GradeCategory

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(category.title)
                    .font(.headline)
                Text("Weight: \(category.weight, specifier: "%.0f")%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(category.earnedScore, specifier: "%.0f") / \(category.maximumScore, specifier: "%.0f")")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(category.title). Weight \(Int(category.weight)) percent. " +
            "Score \(Int(category.earnedScore)) of \(Int(category.maximumScore))."
        )
    }
}

private struct QuizRowView: View {
    let quiz: Quiz

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(quiz.title)
                    .font(.headline)
                Text(quiz.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if let score = quiz.score {
                Text("\(score, specifier: "%.0f") / \(quiz.maximumScore, specifier: "%.0f")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Text("Not Graded")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(quiz.title). \(quiz.date.formatted(date: .abbreviated, time: .omitted))." +
            (quiz.score.map { " Score \(Int($0)) of \(Int(quiz.maximumScore))." } ?? " Not graded.")
        )
    }
}

private struct ExamRowView: View {
    let exam: Exam

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(exam.title)
                .font(.headline)
            HStack(spacing: 6) {
                Text(exam.date.formatted(date: .abbreviated, time: .omitted))
                if !exam.location.isEmpty {
                    Text("· \(exam.location)")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(exam.title). \(exam.date.formatted(date: .abbreviated, time: .omitted))." +
            (exam.location.isEmpty ? "" : " \(exam.location).")
        )
    }
}
