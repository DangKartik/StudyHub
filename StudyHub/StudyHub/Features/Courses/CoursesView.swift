import SwiftUI

struct CoursesView: View {
    let lectureRepository: any LectureRepositoryProtocol

    @State private var viewModel: CoursesViewModel
    @State private var activeSheet: CourseSheet?
    @State private var courseForLectures: Course?

    init(
        appState: AppState,
        courseRepository: any CourseRepositoryProtocol,
        lectureRepository: any LectureRepositoryProtocol
    ) {
        self.lectureRepository = lectureRepository
        _viewModel = State(wrappedValue: CoursesViewModel(
            appState: appState,
            courseRepository: courseRepository
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
                        CourseRowView(
                            course: course,
                            onViewLectures: { courseForLectures = course }
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
                        }
                    }
                }
            }

            if !viewModel.archivedCourses.isEmpty {
                Section("Archived") {
                    ForEach(viewModel.archivedCourses, id: \.id) { course in
                        CourseRowView(
                            course: course,
                            isArchived: true,
                            onViewLectures: { courseForLectures = course }
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

    var body: some View {
        HStack {
            Circle()
                .fill(CourseFormView.colorValue(for: course.courseColor))
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
        }
    }
}
