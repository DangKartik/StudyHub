import SwiftUI

struct FlashcardListView: View {
    @State private var viewModel: FlashcardsViewModel
    @State private var activeSheet: FlashcardSheet?

    init(course: Course, flashcardRepository: any FlashcardRepositoryProtocol) {
        _viewModel = State(wrappedValue: FlashcardsViewModel(
            course: course,
            flashcardRepository: flashcardRepository
        ))
    }

    var body: some View {
        Group {
            if viewModel.flashcards.isEmpty {
                StudyHubEmptyState(
                    icon: "rectangle.stack",
                    title: "No Flashcards Yet",
                    message: "Add flashcards to help you review this course."
                )
            } else {
                list
            }
        }
        .navigationTitle("Flashcards")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    activeSheet = .create
                } label: {
                    Label("Add Flashcard", systemImage: "plus")
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .create:
                FlashcardFormView(viewModel: viewModel, flashcard: nil)
            case .edit(let flashcard):
                FlashcardFormView(viewModel: viewModel, flashcard: flashcard)
            }
        }
        .onAppear {
            viewModel.loadFlashcards()
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

            ForEach(viewModel.flashcards, id: \.id) { flashcard in
                FlashcardRowView(flashcard: flashcard)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        activeSheet = .edit(flashcard)
                    }
                    .accessibilityAddTraits(.isButton)
                    .swipeActions(edge: .trailing) {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            viewModel.deleteFlashcard(flashcard)
                        }
                    }
            }
        }
        .listStyle(.insetGrouped)
    }
}

private enum FlashcardSheet: Identifiable {
    case create
    case edit(Flashcard)

    var id: String {
        switch self {
        case .create: return "create"
        case .edit(let flashcard): return flashcard.id.uuidString
        }
    }
}

private struct FlashcardRowView: View {
    let flashcard: Flashcard

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(flashcard.front)
                .font(.headline)
                .lineLimit(2)
            Text(flashcard.back)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            if let lecture = flashcard.lecture {
                Text(lecture.topic)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(flashcard.front). \(flashcard.back)." +
            (flashcard.lecture.map { " Linked to \($0.topic)." } ?? "")
        )
    }
}
