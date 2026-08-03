import SwiftUI

struct SemesterListView: View {
    let appState: AppState
    let courseRepository: any CourseRepositoryProtocol
    let semesterRepository: any SemesterRepositoryProtocol
    let lectureRepository: any LectureRepositoryProtocol
    let assignmentRepository: any AssignmentRepositoryProtocol
    let readingRepository: any ReadingRepositoryProtocol
    let resourceRepository: any ResourceRepositoryProtocol
    let flashcardRepository: any FlashcardRepositoryProtocol
    let activeRecallRepository: any ActiveRecallRepositoryProtocol
    let noteRepository: any NoteRepositoryProtocol
    let bookmarkRepository: any BookmarkRepositoryProtocol
    let pdfProgressRepository: any PDFProgressRepositoryProtocol
    let pdfService: any PDFServiceProtocol
    let studySessionRepository: any StudySessionRepositoryProtocol
    let userPreferences: UserPreferences

    @State private var viewModel: SemesterViewModel
    @State private var activeSheet: SemesterSheet?
    @State private var semesterForCourses: Semester?

    init(
        appState: AppState,
        courseRepository: any CourseRepositoryProtocol,
        semesterRepository: any SemesterRepositoryProtocol,
        lectureRepository: any LectureRepositoryProtocol,
        assignmentRepository: any AssignmentRepositoryProtocol,
        readingRepository: any ReadingRepositoryProtocol,
        resourceRepository: any ResourceRepositoryProtocol,
        flashcardRepository: any FlashcardRepositoryProtocol,
        activeRecallRepository: any ActiveRecallRepositoryProtocol,
        noteRepository: any NoteRepositoryProtocol,
        bookmarkRepository: any BookmarkRepositoryProtocol,
        pdfProgressRepository: any PDFProgressRepositoryProtocol,
        pdfService: any PDFServiceProtocol,
        studySessionRepository: any StudySessionRepositoryProtocol,
        userPreferences: UserPreferences
    ) {
        self.appState = appState
        self.courseRepository = courseRepository
        self.semesterRepository = semesterRepository
        self.lectureRepository = lectureRepository
        self.assignmentRepository = assignmentRepository
        self.readingRepository = readingRepository
        self.resourceRepository = resourceRepository
        self.flashcardRepository = flashcardRepository
        self.activeRecallRepository = activeRecallRepository
        self.noteRepository = noteRepository
        self.bookmarkRepository = bookmarkRepository
        self.pdfProgressRepository = pdfProgressRepository
        self.pdfService = pdfService
        self.studySessionRepository = studySessionRepository
        self.userPreferences = userPreferences
        _viewModel = State(wrappedValue: SemesterViewModel(
            appState: appState,
            semesterRepository: semesterRepository
        ))
    }

    var body: some View {
        Group {
            if viewModel.activeSemester == nil && viewModel.otherSemesters.isEmpty && viewModel.archivedSemesters.isEmpty {
                StudyHubEmptyState(
                    icon: "calendar.badge.plus",
                    title: "No Semesters Yet",
                    message: "Create your first semester to start organizing your academics.",
                    actionTitle: "Add Semester"
                ) {
                    activeSheet = .create
                }
            } else {
                list
            }
        }
        .navigationTitle("Semesters")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    activeSheet = .create
                } label: {
                    Label("Add Semester", systemImage: "plus")
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .create:
                SemesterFormView(viewModel: viewModel, semester: nil)
            case .edit(let semester):
                SemesterFormView(viewModel: viewModel, semester: semester)
            }
        }
        .navigationDestination(isPresented: Binding(
            get: { semesterForCourses != nil },
            set: { isPresented in
                if !isPresented { semesterForCourses = nil }
            }
        )) {
            if let semesterForCourses {
                SemesterCoursesView(
                    semester: semesterForCourses,
                    appState: appState,
                    courseRepository: courseRepository,
                    semesterRepository: semesterRepository,
                    lectureRepository: lectureRepository,
                    assignmentRepository: assignmentRepository,
                    readingRepository: readingRepository,
                    resourceRepository: resourceRepository,
                    flashcardRepository: flashcardRepository,
                    activeRecallRepository: activeRecallRepository,
                    noteRepository: noteRepository,
                    bookmarkRepository: bookmarkRepository,
                    pdfProgressRepository: pdfProgressRepository,
                    pdfService: pdfService,
                    studySessionRepository: studySessionRepository,
                    userPreferences: userPreferences
                )
            }
        }
        .onAppear {
            viewModel.loadSemesters()
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

            if let active = viewModel.activeSemester {
                Section {
                    SemesterRowView(semester: active, isActive: true)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            semesterForCourses = active
                        }
                        .accessibilityAddTraits(.isButton)
                        .swipeActions(edge: .trailing) {
                            Button("Archive", systemImage: "archivebox") {
                                withAnimation {
                                    viewModel.archive(active)
                                }
                            }
                            .tint(.orange)

                            Button("Edit", systemImage: "pencil") {
                                activeSheet = .edit(active)
                            }
                            .tint(.gray)
                        }
                        .contextMenu {
                            Button("Edit", systemImage: "pencil") {
                                activeSheet = .edit(active)
                            }
                            Button("Archive", systemImage: "archivebox") {
                                withAnimation {
                                    viewModel.archive(active)
                                }
                            }
                        }
                } header: {
                    ListSectionHeaderLabel(title: "Active Semester", icon: "checkmark.seal.fill", tint: .blue)
                }
            }

            if !viewModel.otherSemesters.isEmpty {
                Section {
                    ForEach(viewModel.otherSemesters, id: \.id) { semester in
                        SemesterRowView(
                            semester: semester,
                            isActive: false,
                            onSetActive: {
                                withAnimation {
                                    viewModel.setActive(semester)
                                }
                            }
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            semesterForCourses = semester
                        }
                        .accessibilityAddTraits(.isButton)
                        .swipeActions(edge: .trailing) {
                            Button("Archive", systemImage: "archivebox") {
                                withAnimation {
                                    viewModel.archive(semester)
                                }
                            }
                            .tint(.orange)

                            Button("Set Active", systemImage: "checkmark.circle") {
                                withAnimation {
                                    viewModel.setActive(semester)
                                }
                            }
                            .tint(.blue)

                            Button("Edit", systemImage: "pencil") {
                                activeSheet = .edit(semester)
                            }
                            .tint(.gray)
                        }
                        .contextMenu {
                            Button("Edit", systemImage: "pencil") {
                                activeSheet = .edit(semester)
                            }
                            Button("Set Active", systemImage: "checkmark.circle") {
                                withAnimation {
                                    viewModel.setActive(semester)
                                }
                            }
                            Button("Archive", systemImage: "archivebox") {
                                withAnimation {
                                    viewModel.archive(semester)
                                }
                            }
                        }
                    }
                } header: {
                    ListSectionHeaderLabel(title: "Other Semesters", icon: "calendar", tint: .indigo)
                }
            }

            if !viewModel.archivedSemesters.isEmpty {
                Section {
                    ForEach(viewModel.archivedSemesters, id: \.id) { semester in
                        SemesterRowView(semester: semester, isActive: false, isArchived: true)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                semesterForCourses = semester
                            }
                            .accessibilityAddTraits(.isButton)
                            .swipeActions(edge: .trailing) {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    withAnimation {
                                        viewModel.deleteSemester(semester)
                                    }
                                }

                                Button("Unarchive", systemImage: "arrow.uturn.backward") {
                                    withAnimation {
                                        viewModel.unarchive(semester)
                                    }
                                }
                                .tint(.blue)

                                Button("Edit", systemImage: "pencil") {
                                    activeSheet = .edit(semester)
                                }
                                .tint(.gray)
                            }
                    }
                } header: {
                    ListSectionHeaderLabel(title: "Archived", icon: "archivebox.fill", tint: .gray)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

private enum SemesterSheet: Identifiable {
    case create
    case edit(Semester)

    var id: String {
        switch self {
        case .create: return "create"
        case .edit(let semester): return semester.id.uuidString
        }
    }
}

private struct SemesterRowView: View {
    let semester: Semester
    let isActive: Bool
    var isArchived: Bool = false
    var onSetActive: (() -> Void)? = nil

    /// "Active" only ever reflects the manually-chosen semester (set via
    /// `setActive`) — nothing here compares it against today's date. Without
    /// this, a semester whose end date has long passed keeps showing
    /// "Current" forever with no indication anything is stale. Comparing by
    /// start-of-day (rather than raw `Date` instants) avoids marking a
    /// semester "ended" on its own end date before midnight.
    private var hasEnded: Bool {
        Calendar.current.startOfDay(for: .now) > Calendar.current.startOfDay(for: semester.endDate)
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.courseColor(from: semester.color))
                .frame(width: 12, height: 12)
                .overlay(Circle().strokeBorder(.background, lineWidth: 2))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(semester.name)
                    .font(.headline)
                Text(dateRangeText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                "\(semester.name) semester."
                    + (isActive ? " Current semester." : "")
                    + (isArchived ? " Archived." : (hasEnded ? " Ended." : ""))
            )

            Spacer()

            HStack(spacing: 6) {
                if isArchived {
                    badge("Archived", icon: "archivebox.fill", tint: .gray)
                } else {
                    if hasEnded {
                        badge("Ended", icon: "exclamationmark.circle.fill", tint: .orange)
                    }
                    if isActive {
                        badge("Current", icon: "checkmark.circle.fill", tint: .blue)
                    } else if let onSetActive {
                        Button("Set Active", action: onSetActive)
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.capsule)
                            .controlSize(.small)
                            .tint(.blue)
                            .accessibilityHint("Sets \(semester.name) as the active semester.")
                    }
                }
            }

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
        }
        .padding(.vertical, 6)
    }

    private func badge(_ text: String, icon: String, tint: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption.weight(.medium))
        }
        .foregroundStyle(tint)
        .padding(.horizontal, StudyHubMetrics.chipHorizontalPadding + 2)
        .padding(.vertical, StudyHubMetrics.chipVerticalPadding + 1)
        .background(tint.opacity(0.14), in: Capsule())
    }

    private var dateRangeText: String {
        "\(semester.startDate.formatted(date: .abbreviated, time: .omitted)) – " +
        "\(semester.endDate.formatted(date: .abbreviated, time: .omitted))"
    }
}
