import SwiftUI

struct CoursesView: View {
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

    @State private var viewModel: CoursesViewModel
    @State private var activeSheet: CourseSheet?
    @State private var courseForDetail: Course?
    @State private var searchText: String = ""

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
        _viewModel = State(wrappedValue: CoursesViewModel(
            appState: appState,
            courseRepository: courseRepository,
            semesterRepository: semesterRepository
        ))
    }

    var body: some View {
        Group {
            if viewModel.activeCourses.isEmpty && viewModel.archivedCourses.isEmpty && viewModel.otherSemesterCourses.isEmpty {
                StudyHubEmptyState(
                    icon: "book.closed",
                    title: "No Courses Yet",
                    message: "Add your first course to begin organizing your semester.",
                    actionTitle: "Add Course"
                ) {
                    activeSheet = .create
                }
            } else if filteredActiveCourses.isEmpty && filteredArchivedCourses.isEmpty && filteredOtherSemesterGroups.isEmpty {
                StudyHubEmptyState(
                    icon: "line.3.horizontal.decrease.circle",
                    title: "No Matching Courses",
                    message: "Try a different search."
                )
            } else {
                list
            }
        }
        .navigationTitle("Courses")
        .searchable(text: $searchText, prompt: "Search Courses")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    activeSheet = .create
                } label: {
                    Label("Add Course", systemImage: "plus")
                }
            }
            ToolbarItem(placement: .secondaryAction) {
                NavigationLink {
                    SemesterListView(
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
                } label: {
                    Label("Manage Semesters", systemImage: "calendar")
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .create:
                CourseFormView(viewModel: viewModel, course: nil)
            case .edit(let course):
                CourseFormView(viewModel: viewModel, course: course)
            }
        }
        .navigationDestination(isPresented: Binding(
            get: { courseForDetail != nil },
            set: { isPresented in
                if !isPresented { courseForDetail = nil }
            }
        )) {
            if let courseForDetail {
                CourseDetailView(
                    course: courseForDetail,
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
            viewModel.loadCourses()
        }
    }

    /// Plain client-side filtering over the already-loaded arrays — no
    /// repository-level search, matching how every other list in this app
    /// (Notes/Flashcards/Active Recall) already searches.
    private func matchesSearch(_ course: Course) -> Bool {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return true }
        return course.name.localizedStandardContains(trimmed)
            || course.courseCode.localizedStandardContains(trimmed)
            || course.instructor.localizedStandardContains(trimmed)
            || course.secondInstructor.localizedStandardContains(trimmed)
    }

    private var filteredActiveCourses: [Course] {
        viewModel.activeCourses.filter(matchesSearch)
    }

    private var filteredArchivedCourses: [Course] {
        viewModel.archivedCourses.filter(matchesSearch)
    }

    /// A semester with zero courses should still show up (with its own
    /// empty-state row) so it isn't silently invisible — but only when
    /// there's no active search, since "no courses match your search" and
    /// "this semester has no courses at all" are different messages and the
    /// search field is about the former.
    private var filteredOtherSemesterGroups: [CoursesViewModel.SemesterCourseGroup] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return viewModel.otherSemesterCourses
        }
        return viewModel.otherSemesterCourses.compactMap { group in
            let matching = group.courses.filter(matchesSearch)
            return matching.isEmpty ? nil : CoursesViewModel.SemesterCourseGroup(semester: group.semester, courses: matching)
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

            if let active = viewModel.activeSemester,
               !filteredActiveCourses.isEmpty || searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Section {
                    if filteredActiveCourses.isEmpty {
                        emptySemesterRow(active)
                    } else {
                        ForEach(filteredActiveCourses, id: \.id) { course in
                            editableCourseRow(course)
                        }
                    }
                } header: {
                    listSectionHeader(active.name, icon: "book.closed.fill", tint: .blue)
                }
            }

            ForEach(filteredOtherSemesterGroups) { group in
                Section {
                    if group.courses.isEmpty {
                        emptySemesterRow(group.semester)
                    } else {
                        ForEach(group.courses, id: \.id) { course in
                            editableCourseRow(course)
                        }
                    }
                } header: {
                    listSectionHeader(group.semester.name, icon: "calendar", tint: .indigo)
                }
            }

            if !filteredArchivedCourses.isEmpty {
                Section {
                    ForEach(filteredArchivedCourses, id: \.id) { course in
                        CourseRowView(course: course, isArchived: true)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                courseForDetail = course
                            }
                            .accessibilityAddTraits(.isButton)
                            .swipeActions(edge: .trailing) {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    withAnimation {
                                        viewModel.deleteCourse(course)
                                    }
                                }

                                Button("Unarchive", systemImage: "arrow.uturn.backward") {
                                    withAnimation {
                                        viewModel.unarchive(course)
                                    }
                                }
                                .tint(.blue)

                                Button("Edit", systemImage: "pencil") {
                                    activeSheet = .edit(course)
                                }
                                .tint(.gray)
                            }
                    }
                } header: {
                    listSectionHeader("Archived Courses", icon: "archivebox.fill", tint: .gray)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    /// Small tinted-icon + title combo for `List` section headers — same
    /// language as Home's section headers, scaled down to fit inline with
    /// a system section header's default text size instead of competing
    /// with it.
    private func listSectionHeader(_ title: String, icon: String, tint: Color) -> some View {
        ListSectionHeaderLabel(title: title, icon: icon, tint: tint)
    }

    /// Shown in place of a course row for a semester (active or otherwise)
    /// that has no courses yet — previously such a semester either didn't
    /// appear at all (other semesters) or the whole section silently
    /// vanished (active), giving no indication of what to do next.
    private func emptySemesterRow(_ semester: Semester) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "tray")
                .foregroundStyle(.secondary)
            Text("No courses added yet")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(semester.name) has no courses yet.")
    }

    @ViewBuilder
    private func editableCourseRow(_ course: Course) -> some View {
        CourseRowView(course: course)
        .contentShape(Rectangle())
        .onTapGesture {
            courseForDetail = course
        }
        .accessibilityAddTraits(.isButton)
        .swipeActions(edge: .trailing) {
            Button("Archive", systemImage: "archivebox") {
                withAnimation {
                    viewModel.archive(course)
                }
            }
            .tint(.orange)

            Button("Edit", systemImage: "pencil") {
                activeSheet = .edit(course)
            }
            .tint(.gray)
        }
        // Email moved to the Course Page's toolbar — no longer duplicated
        // as a swipe action here.
        .contextMenu {
            Button("Edit", systemImage: "pencil") {
                activeSheet = .edit(course)
            }
            Button("Archive", systemImage: "archivebox") {
                withAnimation {
                    viewModel.archive(course)
                }
            }
        }
    }
}

private enum CourseSheet: Identifiable {
    case create
    case edit(Course)

    var id: String {
        switch self {
        case .create: return "create"
        case .edit(let course): return course.id.uuidString
        }
    }
}

/// Now just an entry point into `CourseDetailView` (tap) — the row used to
/// carry a separate bordered button per feature (Lectures/Assignments/
/// Readings/Resources/Grades/Flashcards/Active Recall/Notes all crammed
/// into one HStack, which is what was overflowing off the edge of the
/// screen on courses with long names). All of those are still reachable,
/// just from inside the Course Page instead of the row itself.
/// Not `private` — reused by `SemesterCoursesView`'s per-semester course
/// list so both places render an identical row instead of two versions.
struct CourseRowView: View {
    let course: Course
    var isArchived: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.courseColor(from: course.courseColor))
                .frame(width: 12, height: 12)
                .overlay(Circle().strokeBorder(.background, lineWidth: 2))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(course.name)
                    .font(.headline)
                if !course.courseCode.isEmpty {
                    Text(course.courseCode)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                if !course.instructorDisplayName.isEmpty {
                    Text(course.instructorDisplayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                "\(course.name) \(course.courseCode)." + (isArchived ? " Archived." : "")
            )

            Spacer()

            if isArchived {
                Text("Archived")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, StudyHubMetrics.chipHorizontalPadding)
                    .padding(.vertical, StudyHubMetrics.chipVerticalPadding)
                    .background(Color(uiColor: .tertiarySystemFill), in: Capsule())
            }

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
        }
        .padding(.vertical, 6)
    }
}
