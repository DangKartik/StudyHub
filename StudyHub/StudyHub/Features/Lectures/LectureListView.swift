import SwiftUI

struct LectureListView: View {
    let activeRecallRepository: any ActiveRecallRepositoryProtocol
    let flashcardRepository: any FlashcardRepositoryProtocol
    let noteRepository: any NoteRepositoryProtocol
    let bookmarkRepository: any BookmarkRepositoryProtocol
    let pdfProgressRepository: any PDFProgressRepositoryProtocol
    let pdfService: any PDFServiceProtocol
    let userPreferences: UserPreferences

    @State private var viewModel: LectureViewModel
    @State private var activeSheet: LectureSheet?
    @State private var lectureForActiveRecall: Lecture?
    @State private var lectureForNotes: Lecture?

    init(
        course: Course,
        lectureRepository: any LectureRepositoryProtocol,
        activeRecallRepository: any ActiveRecallRepositoryProtocol,
        flashcardRepository: any FlashcardRepositoryProtocol,
        noteRepository: any NoteRepositoryProtocol,
        bookmarkRepository: any BookmarkRepositoryProtocol,
        pdfProgressRepository: any PDFProgressRepositoryProtocol,
        pdfService: any PDFServiceProtocol,
        userPreferences: UserPreferences
    ) {
        self.activeRecallRepository = activeRecallRepository
        self.flashcardRepository = flashcardRepository
        self.noteRepository = noteRepository
        self.bookmarkRepository = bookmarkRepository
        self.pdfProgressRepository = pdfProgressRepository
        self.pdfService = pdfService
        self.userPreferences = userPreferences
        _viewModel = State(wrappedValue: LectureViewModel(
            course: course,
            lectureRepository: lectureRepository
        ))
    }

    var body: some View {
        Group {
            if viewModel.lectures.isEmpty {
                StudyHubEmptyState(
                    icon: "calendar.badge.plus",
                    title: "No Lectures Yet",
                    message: "Add lectures to organize your course schedule.",
                    actionTitle: "Add Lecture"
                ) {
                    activeSheet = .create
                }
            } else {
                list
            }
        }
        .navigationTitle("Lectures")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    activeSheet = .create
                } label: {
                    Label("Add Lecture", systemImage: "plus")
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .create:
                LectureFormView(
                    viewModel: viewModel,
                    lecture: nil,
                    bookmarkRepository: bookmarkRepository,
                    pdfProgressRepository: pdfProgressRepository,
                    pdfService: pdfService,
                    userPreferences: userPreferences
                )
            case .edit(let lecture):
                LectureFormView(
                    viewModel: viewModel,
                    lecture: lecture,
                    bookmarkRepository: bookmarkRepository,
                    pdfProgressRepository: pdfProgressRepository,
                    pdfService: pdfService,
                    userPreferences: userPreferences
                )
            }
        }
        .navigationDestination(isPresented: Binding(
            get: { lectureForActiveRecall != nil },
            set: { isPresented in
                if !isPresented { lectureForActiveRecall = nil }
            }
        )) {
            if let lectureForActiveRecall {
                ActiveRecallListView(
                    lecture: lectureForActiveRecall,
                    activeRecallRepository: activeRecallRepository,
                    noteRepository: noteRepository,
                    flashcardRepository: flashcardRepository
                )
            }
        }
        .navigationDestination(isPresented: Binding(
            get: { lectureForNotes != nil },
            set: { isPresented in
                if !isPresented { lectureForNotes = nil }
            }
        )) {
            if let lectureForNotes {
                NotesListView(
                    lecture: lectureForNotes,
                    noteRepository: noteRepository,
                    bookmarkRepository: bookmarkRepository,
                    pdfProgressRepository: pdfProgressRepository,
                    pdfService: pdfService
                )
            }
        }
        .onAppear {
            viewModel.loadLectures()
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

            ForEach(viewModel.lectures, id: \.id) { lecture in
                LectureRowView(lecture: lecture)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        activeSheet = .edit(lecture)
                    }
                    .accessibilityAddTraits(.isButton)
                    .swipeActions(edge: .trailing) {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            viewModel.deleteLecture(lecture)
                        }

                        Button("Notes", systemImage: "note.text") {
                            lectureForNotes = lecture
                        }
                        .tint(.teal)

                        Button("Active Recall", systemImage: "brain.head.profile") {
                            lectureForActiveRecall = lecture
                        }
                        .tint(.purple)
                    }
                    .contextMenu {
                        Button("Active Recall", systemImage: "brain.head.profile") {
                            lectureForActiveRecall = lecture
                        }
                        Button("Notes", systemImage: "note.text") {
                            lectureForNotes = lecture
                        }
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            viewModel.deleteLecture(lecture)
                        }
                    }
            }
        }
        .listStyle(.insetGrouped)
    }
}

private enum LectureSheet: Identifiable {
    case create
    case edit(Lecture)

    var id: String {
        switch self {
        case .create: return "create"
        case .edit(let lecture): return lecture.id.uuidString
        }
    }
}

/// No more inline "Active Recall"/"Notes" buttons crammed into the row —
/// same lesson as `CourseRowView`'s own redesign (a per-feature button strip
/// stops fitting once there's more than one or two of them). Both are still
/// reachable, just via swipe actions and the context menu instead of taking
/// up permanent space in every row.
private struct LectureRowView: View {
    let lecture: Lecture

    private static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }()

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()

    private var timeRangeText: String {
        "\(lecture.startTime.formatted(date: .omitted, time: .shortened)) – \(lecture.endTime.formatted(date: .omitted, time: .shortened))"
    }

    /// A Calendar-app-style date badge (month + day) instead of a single
    /// generic icon repeated identically on every row — this actually
    /// carries information (which day this lecture falls on, at a glance)
    /// rather than just decoration, and gives the date its own visual
    /// block so the text lines next to it don't have to cram date and time
    /// together into one run-on line.
    private var dateBadge: some View {
        VStack(spacing: 1) {
            Text(Self.monthFormatter.string(from: lecture.date).uppercased())
                .font(.caption2.weight(.bold))
            Text(Self.dayFormatter.string(from: lecture.date))
                .font(.title3.weight(.bold))
                .monospacedDigit()
        }
        .foregroundStyle(.pink)
        .frame(width: 46, height: 46)
        .background(Color.pink.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
        .accessibilityHidden(true)
    }

    var body: some View {
        HStack(spacing: 14) {
            dateBadge

            VStack(alignment: .leading, spacing: 4) {
                Text(lecture.topic)
                    .font(.headline)
                Label(timeRangeText, systemImage: "clock")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if !lecture.location.isEmpty {
                    Label(lecture.location, systemImage: "location")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                "\(lecture.topic). \(lecture.date.formatted(date: .abbreviated, time: .omitted)), \(timeRangeText)."
                    + (lecture.location.isEmpty ? "" : " \(lecture.location).")
            )

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
        }
        .padding(.vertical, 6)
    }
}
