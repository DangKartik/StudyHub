import SwiftUI

struct ActiveRecallListView: View {
    @State private var viewModel: ActiveRecallViewModel
    @State private var activeSheet: ActiveRecallSheet?

    init(lecture: Lecture, activeRecallRepository: any ActiveRecallRepositoryProtocol) {
        _viewModel = State(wrappedValue: ActiveRecallViewModel(
            lecture: lecture,
            activeRecallRepository: activeRecallRepository
        ))
    }

    var body: some View {
        Group {
            if viewModel.questions.isEmpty {
                StudyHubEmptyState(
                    icon: "brain.head.profile",
                    title: "No Recall Questions Yet",
                    message: "Add questions to test your understanding of this lecture."
                )
            } else {
                list
            }
        }
        .navigationTitle("Active Recall")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    activeSheet = .create
                } label: {
                    Label("Add Question", systemImage: "plus")
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .create:
                ActiveRecallFormView(viewModel: viewModel, recallQuestion: nil)
            case .edit(let recallQuestion):
                ActiveRecallFormView(viewModel: viewModel, recallQuestion: recallQuestion)
            }
        }
        .onAppear {
            viewModel.loadQuestions()
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

            ForEach(viewModel.questions, id: \.id) { recallQuestion in
                ActiveRecallRowView(recallQuestion: recallQuestion)
                    .onTapGesture {
                        activeSheet = .edit(recallQuestion)
                    }
                    .swipeActions(edge: .trailing) {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            viewModel.deleteQuestion(recallQuestion)
                        }
                    }
            }
        }
        .listStyle(.insetGrouped)
    }
}

private enum ActiveRecallSheet: Identifiable {
    case create
    case edit(ActiveRecallQuestion)

    var id: String {
        switch self {
        case .create: return "create"
        case .edit(let recallQuestion): return recallQuestion.id.uuidString
        }
    }
}

private struct ActiveRecallRowView: View {
    let recallQuestion: ActiveRecallQuestion

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(recallQuestion.question)
                .font(.headline)
                .lineLimit(2)
            Text(recallQuestion.questionType.label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(recallQuestion.question). \(recallQuestion.questionType.label).")
    }
}
