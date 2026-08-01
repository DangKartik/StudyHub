import SwiftUI

struct GlobalSearchView: View {
    let appState: AppState
    let semesterRepository: any SemesterRepositoryProtocol
    let noteRepository: any NoteRepositoryProtocol
    let flashcardRepository: any FlashcardRepositoryProtocol
    let activeRecallRepository: any ActiveRecallRepositoryProtocol
    let readingRepository: any ReadingRepositoryProtocol
    let courseRepository: any CourseRepositoryProtocol
    let bookmarkRepository: any BookmarkRepositoryProtocol
    let pdfProgressRepository: any PDFProgressRepositoryProtocol
    let pdfService: any PDFServiceProtocol

    @State private var viewModel: GlobalSearchViewModel
    @State private var searchText = ""
    @State private var activeDestination: SearchDestination?

    private static let sectionOrder = ["Notes", "Flashcards", "Active Recall", "Readings", "Courses"]

    init(
        appState: AppState,
        semesterRepository: any SemesterRepositoryProtocol,
        noteRepository: any NoteRepositoryProtocol,
        flashcardRepository: any FlashcardRepositoryProtocol,
        activeRecallRepository: any ActiveRecallRepositoryProtocol,
        readingRepository: any ReadingRepositoryProtocol,
        courseRepository: any CourseRepositoryProtocol,
        bookmarkRepository: any BookmarkRepositoryProtocol,
        pdfProgressRepository: any PDFProgressRepositoryProtocol,
        pdfService: any PDFServiceProtocol
    ) {
        self.appState = appState
        self.semesterRepository = semesterRepository
        self.noteRepository = noteRepository
        self.flashcardRepository = flashcardRepository
        self.activeRecallRepository = activeRecallRepository
        self.readingRepository = readingRepository
        self.courseRepository = courseRepository
        self.bookmarkRepository = bookmarkRepository
        self.pdfProgressRepository = pdfProgressRepository
        self.pdfService = pdfService
        _viewModel = State(wrappedValue: GlobalSearchViewModel(
            noteRepository: noteRepository,
            flashcardRepository: flashcardRepository,
            activeRecallRepository: activeRecallRepository,
            readingRepository: readingRepository,
            courseRepository: courseRepository
        ))
    }

    private var groupedResults: [(section: String, results: [GlobalSearchResult])] {
        let all = viewModel.results(for: searchText)
        return Self.sectionOrder.compactMap { section in
            let matching = all.filter { $0.sectionTitle == section }
            return matching.isEmpty ? nil : (section, matching)
        }
    }

    var body: some View {
        Group {
            if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                StudyHubEmptyState(
                    icon: "magnifyingglass",
                    title: "Search StudyHub",
                    message: "Search across Notes, Flashcards, Active Recall, Readings, and Courses."
                )
            } else if groupedResults.isEmpty {
                StudyHubEmptyState(
                    icon: "line.3.horizontal.decrease.circle",
                    title: "No Results",
                    message: "Try a different search."
                )
            } else {
                List {
                    ForEach(groupedResults, id: \.section) { group in
                        Section(group.section) {
                            ForEach(group.results) { result in
                                Button {
                                    open(result)
                                } label: {
                                    resultRow(result)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search Notes, Flashcards, Questions…")
        .fullScreenCover(item: $activeDestination) { destination in
            destinationView(destination)
        }
        .onAppear {
            viewModel.loadAll()
        }
    }

    private func resultRow(_ result: GlobalSearchResult) -> some View {
        HStack(spacing: 12) {
            Image(systemName: result.icon)
                .foregroundStyle(.secondary)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(result.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                if let subtitle = result.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        // Without this, the row's tap target only covers its content's
        // intrinsic width, not the full row — same fix already applied to
        // every other list row in the app (Notes/Flashcards/etc.).
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }

    private func open(_ result: GlobalSearchResult) {
        switch result.kind {
        case .note(let note): activeDestination = .note(note)
        case .flashcard(let card): activeDestination = .flashcard(card)
        case .question(let question): activeDestination = .question(question)
        case .reading(let reading): activeDestination = .reading(reading)
        case .course(let course): activeDestination = .course(course)
        }
    }

    @ViewBuilder
    private func destinationView(_ destination: SearchDestination) -> some View {
        switch destination {
        case .note(let note):
            NoteDetailView(
                note: note,
                viewModel: NotesViewModel(scope: .global, noteRepository: noteRepository),
                bookmarkRepository: bookmarkRepository,
                pdfProgressRepository: pdfProgressRepository,
                pdfService: pdfService
            )
        case .flashcard(let card):
            // Opens straight into review (not the edit form) — search is
            // for "go study this," matching what tapping a row in
            // FlashcardListView itself does.
            FlashcardReviewView(cards: [card], flashcardRepository: flashcardRepository)
        case .question(let question):
            ActiveRecallReviewView(questions: [question], activeRecallRepository: activeRecallRepository)
        case .reading(let reading):
            // Reading has no standalone detail screen anywhere in the app —
            // every entry point opens it via its Course's Reading list, so
            // search does the same rather than duplicating that list's
            // PDF-opening logic just for this one entry point.
            if let course = reading.course {
                NavigationStack {
                    ReadingListView(
                        course: course,
                        readingRepository: readingRepository,
                        bookmarkRepository: bookmarkRepository,
                        pdfProgressRepository: pdfProgressRepository,
                        pdfService: pdfService
                    )
                }
            }
        case .course(let course):
            // A real Course "landing" destination is still to come — this
            // opens the same edit form tapping a course row already does
            // elsewhere in the app, as a placeholder until that exists.
            CourseFormView(
                viewModel: CoursesViewModel(appState: appState, courseRepository: courseRepository, semesterRepository: semesterRepository),
                course: course
            )
        }
    }
}

private enum SearchDestination: Identifiable {
    case note(Note)
    case flashcard(Flashcard)
    case question(ActiveRecallQuestion)
    case reading(Reading)
    case course(Course)

    var id: UUID {
        switch self {
        case .note(let note): return note.id
        case .flashcard(let card): return card.id
        case .question(let question): return question.id
        case .reading(let reading): return reading.id
        case .course(let course): return course.id
        }
    }
}
