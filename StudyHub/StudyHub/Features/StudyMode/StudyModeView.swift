import SwiftUI

/// Study Mode entry point (Phase 4.3, requirement 1) — pick a Course,
/// optionally a Lecture, then start a session. The actual session lives in
/// `StudySessionWorkspaceView`, presented full-screen so there's no
/// navigating back and forth once a session begins (requirement 2).
struct StudyModeView: View {
    let courseRepository: any CourseRepositoryProtocol
    let studySessionRepository: any StudySessionRepositoryProtocol
    let readingRepository: any ReadingRepositoryProtocol
    let noteRepository: any NoteRepositoryProtocol
    let flashcardRepository: any FlashcardRepositoryProtocol
    let activeRecallRepository: any ActiveRecallRepositoryProtocol
    let lectureRepository: any LectureRepositoryProtocol
    let bookmarkRepository: any BookmarkRepositoryProtocol
    let pdfProgressRepository: any PDFProgressRepositoryProtocol
    let pdfService: any PDFServiceProtocol

    @State private var courses: [Course] = []
    @State private var selectedCourse: Course?
    @State private var selectedLecture: Lecture?
    @State private var activeSession: StudySessionViewModel?

    private var availableLectures: [Lecture] {
        selectedCourse?.lectures.sorted { $0.date < $1.date } ?? []
    }

    var body: some View {
        Group {
            if courses.isEmpty {
                StudyHubEmptyState(
                    icon: "brain.head.profile",
                    title: "No Courses Yet",
                    message: "Add a course before starting a Study Session."
                )
            } else {
                form
            }
        }
        .navigationTitle("Study Mode")
        .onAppear(perform: loadCourses)
        .fullScreenCover(item: $activeSession) { sessionViewModel in
            StudySessionWorkspaceView(
                sessionViewModel: sessionViewModel,
                noteRepository: noteRepository,
                lectureRepository: lectureRepository,
                flashcardRepository: flashcardRepository,
                activeRecallRepository: activeRecallRepository,
                readingRepository: readingRepository,
                bookmarkRepository: bookmarkRepository,
                pdfProgressRepository: pdfProgressRepository,
                pdfService: pdfService
            )
        }
    }

    private var form: some View {
        Form {
            Section("Course") {
                Picker("Course", selection: $selectedCourse) {
                    Text("Select a Course").tag(nil as Course?)
                    ForEach(courses, id: \.id) { course in
                        Text(course.name).tag(Optional(course))
                    }
                }
                .onChange(of: selectedCourse) {
                    selectedLecture = nil
                }
            }

            if selectedCourse != nil {
                Section("Lecture (Optional)") {
                    Picker("Lecture", selection: $selectedLecture) {
                        Text("Whole Course").tag(nil as Lecture?)
                        ForEach(availableLectures, id: \.id) { lecture in
                            Text(lecture.topic).tag(Optional(lecture))
                        }
                    }
                }
            }

            Section {
                Button {
                    startSession()
                } label: {
                    Text("Start Study Session")
                        .frame(maxWidth: .infinity)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedCourse == nil)
                .listRowInsets(EdgeInsets())
                .padding()
            }
        }
    }

    private func loadCourses() {
        courses = ((try? courseRepository.fetchAll()) ?? []).filter { !$0.isArchived }
    }

    private func startSession() {
        guard let selectedCourse else { return }
        let sessionViewModel = StudySessionViewModel(
            course: selectedCourse,
            lecture: selectedLecture,
            studySessionRepository: studySessionRepository,
            readingRepository: readingRepository,
            pdfProgressRepository: pdfProgressRepository
        )
        sessionViewModel.start()
        activeSession = sessionViewModel
    }
}
