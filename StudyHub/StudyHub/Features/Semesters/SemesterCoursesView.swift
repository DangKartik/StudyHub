import SwiftUI

/// Pushed when tapping a semester in `SemesterListView` — a read-only,
/// single-semester slice of the same course list Courses shows for
/// everything at once. Reads straight off `Semester.courses` (the existing
/// SwiftData inverse relationship) instead of re-querying a repository, and
/// reuses `CourseRowView`/`CourseDetailView` unmodified so a course opened
/// from here looks and behaves identically to one opened from the Courses
/// tab.
struct SemesterCoursesView: View {
    let semester: Semester
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

    @State private var courseForDetail: Course?

    private var sortedCourses: [Course] {
        semester.courses.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    var body: some View {
        Group {
            if sortedCourses.isEmpty {
                StudyHubEmptyState(
                    icon: "book.closed",
                    title: "No Courses",
                    message: "\(semester.name) doesn't have any courses yet."
                )
            } else {
                List {
                    ForEach(sortedCourses, id: \.id) { course in
                        CourseRowView(course: course, isArchived: course.isArchived)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                courseForDetail = course
                            }
                            .accessibilityAddTraits(.isButton)
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle(semester.name)
        .navigationBarTitleDisplayMode(.inline)
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
    }
}
