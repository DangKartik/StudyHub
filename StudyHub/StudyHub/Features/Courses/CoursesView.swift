import SwiftUI

struct CoursesView: View {
    let lectureRepository: any LectureRepositoryProtocol
    let assignmentRepository: any AssignmentRepositoryProtocol

    @State private var viewModel: CoursesViewModel
    @State private var activeSheet: CourseSheet?
    @State private var courseForLectures: Course?
    @State private var courseForAssignments: Course?
    @Environment(\.openURL) private var openURL

    init(
        appState: AppState,
        courseRepository: any CourseRepositoryProtocol,
        semesterRepository: any SemesterRepositoryProtocol,
        lectureRepository: any LectureRepositoryProtocol,
        assignmentRepository: any AssignmentRepositoryProtocol
    ) {
        self.lectureRepository = lectureRepository
        self.assignmentRepository = assignmentRepository
        _viewModel = State(wrappedValue: CoursesViewModel(
            appState: appState,
            courseRepository: courseRepository,
            semesterRepository: semesterRepository
        ))
    }

    var body: some View {
        Group {
            if viewModel.activeCourses.isEmpty && viewModel.archivedCourses.isEmpty {
                StudyHubEmptyState(
                    icon: "book.closed",
                    title: "No Courses Yet",
                    message: "Add your first course to begin organizing your semester."
                )
            } else {
                list
            }
        }
        .navigationTitle("Courses")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    activeSheet = .create
                } label: {
                    Label("Add Course", systemImage: "plus")
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
            get: { courseForLectures != nil },
            set: { isPresented in
                if !isPresented { courseForLectures = nil }
            }
        )) {
            if let courseForLectures {
                LectureListView(course: courseForLectures, lectureRepository: lectureRepository)
            }
        }
        .navigationDestination(isPresented: Binding(
            get: { courseForAssignments != nil },
            set: { isPresented in
                if !isPresented { courseForAssignments = nil }
            }
        )) {
            if let courseForAssignments {
                AssignmentListView(course: courseForAssignments, assignmentRepository: assignmentRepository)
            }
        }
        .onAppear {
            viewModel.loadCourses()
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

            if !viewModel.activeCourses.isEmpty {
                Section("Active Courses") {
                    ForEach(viewModel.activeCourses, id: \.id) { course in
                        editableCourseRow(course)
                    }
                }
            }

            ForEach(viewModel.otherSemesterCourses) { group in
                Section(group.semester.name) {
                    ForEach(group.courses, id: \.id) { course in
                        editableCourseRow(course)
                    }
                }
            }

            if !viewModel.archivedCourses.isEmpty {
                Section("Archived Courses") {
                    ForEach(viewModel.archivedCourses, id: \.id) { course in
                        CourseRowView(
                            course: course,
                            isArchived: true,
                            onViewLectures: { courseForLectures = course },
                            onViewAssignments: { courseForAssignments = course }
                        )
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
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    @ViewBuilder
    private func editableCourseRow(_ course: Course) -> some View {
        CourseRowView(
            course: course,
            onViewLectures: { courseForLectures = course },
            onViewAssignments: { courseForAssignments = course }
        )
        .onTapGesture {
            activeSheet = .edit(course)
        }
        .swipeActions(edge: .trailing) {
            Button("Archive", systemImage: "archivebox") {
                withAnimation {
                    viewModel.archive(course)
                }
            }
            .tint(.orange)

            if let mailURL = URL.mailto(course.email) {
                Button("Email", systemImage: "envelope") {
                    openURL(mailURL)
                }
                .tint(.blue)
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

private struct CourseRowView: View {
    let course: Course
    var isArchived: Bool = false
    var onViewLectures: (() -> Void)? = nil
    var onViewAssignments: (() -> Void)? = nil

    @Environment(\.openURL) private var openURL

    var body: some View {
        HStack {
            Circle()
                .fill(Color.courseColor(from: course.courseColor))
                .frame(width: 12, height: 12)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(course.courseCode)
                        .font(.headline)
                    Text(course.name)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                if !course.instructor.isEmpty {
                    Text(course.instructor)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let mailURL = URL.mailto(course.email) {
                    Button {
                        openURL(mailURL)
                    } label: {
                        Text(course.email)
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                    .buttonStyle(.plain)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                "\(course.courseCode) \(course.name)." + (isArchived ? " Archived." : "")
            )

            Spacer()

            if isArchived {
                Text("Archived")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let onViewLectures {
                Button(action: onViewLectures) {
                    Label("Lectures", systemImage: "list.bullet")
                }
                .buttonStyle(.bordered)
                .font(.caption)
                .accessibilityLabel("View lectures for \(course.name).")
            }

            if let onViewAssignments {
                Button(action: onViewAssignments) {
                    Label("Assignments", systemImage: "checklist")
                }
                .buttonStyle(.bordered)
                .font(.caption)
                .accessibilityLabel("View assignments for \(course.name).")
            }
        }
    }
}
