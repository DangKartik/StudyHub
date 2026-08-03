import SwiftUI

struct GradesListView: View {
    @State private var viewModel: GradesViewModel
    @State private var activeSheet: GradeSheet?
    @Environment(\.colorScheme) private var colorScheme
    let bookmarkRepository: any BookmarkRepositoryProtocol
    let pdfProgressRepository: any PDFProgressRepositoryProtocol
    let pdfService: any PDFServiceProtocol

    init(
        course: Course,
        courseRepository: any CourseRepositoryProtocol,
        bookmarkRepository: any BookmarkRepositoryProtocol,
        pdfProgressRepository: any PDFProgressRepositoryProtocol,
        pdfService: any PDFServiceProtocol,
        notificationManager: any NotificationSchedulingProtocol,
        calendarSyncService: any CalendarSyncServiceProtocol,
        calendarRepository: any CalendarRepositoryProtocol,
        userPreferences: UserPreferences
    ) {
        _viewModel = State(wrappedValue: GradesViewModel(
            course: course,
            courseRepository: courseRepository,
            notificationManager: notificationManager,
            calendarSyncService: calendarSyncService,
            calendarRepository: calendarRepository,
            userPreferences: userPreferences
        ))
        self.bookmarkRepository = bookmarkRepository
        self.pdfProgressRepository = pdfProgressRepository
        self.pdfService = pdfService
    }

    var body: some View {
        Group {
            if viewModel.assessments.isEmpty {
                StudyHubEmptyState(
                    icon: "chart.bar",
                    title: "No Grades Yet",
                    message: "Add a quiz or exam to start tracking this course.",
                    actionTitle: "Add Quiz or Exam"
                ) {
                    activeSheet = .createAssessment
                }
            } else {
                list
            }
        }
        .navigationTitle("Grades")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    activeSheet = .createAssessment
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .createAssessment:
                AssessmentFormView(
                    viewModel: viewModel,
                    assessment: nil,
                    bookmarkRepository: bookmarkRepository,
                    pdfProgressRepository: pdfProgressRepository,
                    pdfService: pdfService
                )
            case .editAssessment(let assessment):
                AssessmentFormView(
                    viewModel: viewModel,
                    assessment: assessment,
                    bookmarkRepository: bookmarkRepository,
                    pdfProgressRepository: pdfProgressRepository,
                    pdfService: pdfService
                )
            }
        }
        .onAppear {
            viewModel.loadGrades()
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

            Section {
                gradeHeroCard

                Picker(selection: Binding(
                    get: { viewModel.finalLetterGrade },
                    set: { viewModel.setFinalLetterGrade($0) }
                )) {
                    Text("Not Final Yet").tag(nil as LetterGrade?)
                    ForEach(viewModel.isPassFail ? LetterGrade.passFailCases : LetterGrade.standardCases, id: \.self) { letter in
                        Text(letter.rawValue).tag(Optional(letter))
                    }
                } label: {
                    Label("Final Letter Grade", systemImage: "rosette")
                }

                Toggle(isOn: Binding(
                    get: { viewModel.isPassFail },
                    set: { viewModel.setPassFail($0) }
                )) {
                    Label("Pass/Fail Course", systemImage: "checkmark.circle")
                }
            } footer: {
                Text(viewModel.isPassFail
                    ? "Pass/Fail courses count toward credits completed, never toward GPA."
                    : "Set the Final Letter Grade once this course is fully graded — it's what feeds your GPA in Analytics.")
            }

            Section("Quizzes & Exams") {
                ForEach(viewModel.assessments, id: \.id) { assessment in
                    AssessmentRowView(assessment: assessment)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            activeSheet = .editAssessment(assessment)
                        }
                        .accessibilityAddTraits(.isButton)
                        .swipeActions(edge: .trailing) {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                viewModel.deleteAssessment(assessment)
                            }
                        }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    /// Same "tinted hero" composition as Home's greeting card — once a
    /// Final Letter Grade is set, this swaps from the plain percentage to
    /// the letter itself, tinted by grade quality (green for A-range, red
    /// for F, etc.) rather than a fixed accent color, so the color itself
    /// carries information. The Final Letter Grade picker stays a normal
    /// row right below it either way — this only changes what's shown
    /// above, never whether it's still changeable.
    private var gradeHeroCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let letter = viewModel.finalLetterGrade {
                Text("Final Grade")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(letter.tintColor)
                Text(letter.rawValue)
                    .font(.system(.largeTitle, design: .rounded).weight(.heavy))
            } else if let currentGrade = viewModel.currentGrade {
                Text("Current Grade")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text("\(currentGrade, specifier: "%.1f")%")
                    .font(.system(.largeTitle, design: .rounded).weight(.heavy))
            } else {
                Text("Current Grade")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text("No Grade Yet")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(heroBackground, in: RoundedRectangle(cornerRadius: StudyHubMetrics.cardCornerRadius))
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }

    private var heroTint: Color {
        viewModel.finalLetterGrade?.tintColor ?? .accentColor
    }

    private var heroBackground: some ShapeStyle {
        LinearGradient(
            colors: colorScheme == .dark
                ? [heroTint.opacity(0.35), heroTint.opacity(0.12)]
                : [heroTint.opacity(0.16), heroTint.opacity(0.03)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

private enum GradeSheet: Identifiable {
    case createAssessment
    case editAssessment(Assessment)

    var id: String {
        switch self {
        case .createAssessment: return "createAssessment"
        case .editAssessment(let assessment): return assessment.id.uuidString
        }
    }
}

private struct AssessmentRowView: View {
    let assessment: Assessment

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: assessment.kind.icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(assessment.kind.color)
                .frame(width: 36, height: 36)
                .background(assessment.kind.color.opacity(0.14), in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(assessment.title)
                    .font(.headline)
                HStack(spacing: 6) {
                    Text(assessment.kind.label)
                    Text("· \(assessment.date.formatted(date: .abbreviated, time: .shortened))")
                    if !assessment.location.isEmpty {
                        Text("· \(assessment.location)")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 4) {
                if let score = assessment.score {
                    Text("\(score, specifier: "%.0f") / \(assessment.maximumScore, specifier: "%.0f")")
                        .font(.subheadline.weight(.medium))
                } else {
                    Text("Not Graded")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let rating = assessment.reflectionRating {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                        Text("\(rating)")
                            .font(.caption2.weight(.medium))
                    }
                    .foregroundStyle(.yellow)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(assessment.kind.label): \(assessment.title). \(assessment.date.formatted(date: .abbreviated, time: .omitted))." +
            (assessment.location.isEmpty ? "" : " \(assessment.location).") +
            (assessment.score.map { " Score \(Int($0)) of \(Int(assessment.maximumScore))." } ?? " Not graded.") +
            (assessment.reflectionRating.map { " Your reflection: \($0) of 5 stars." } ?? "")
        )
    }
}
