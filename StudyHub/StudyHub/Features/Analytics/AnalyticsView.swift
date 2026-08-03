import SwiftUI

/// Dedicated Analytics dashboard (Phase 4.5) — entirely read-only, computed
/// fresh from existing repositories each time it appears. Reuses the
/// sidebar's existing `.statistics` destination, which had no real screen
/// behind it until now (same dead-stub shape `.resources` had before it was
/// removed).
struct AnalyticsView: View {
    let appState: AppState
    let courseRepository: any CourseRepositoryProtocol
    let semesterRepository: any SemesterRepositoryProtocol
    let readingRepository: any ReadingRepositoryProtocol
    let pdfProgressRepository: any PDFProgressRepositoryProtocol
    let flashcardRepository: any FlashcardRepositoryProtocol
    let activeRecallRepository: any ActiveRecallRepositoryProtocol
    let studySessionRepository: any StudySessionRepositoryProtocol
    let userPreferences: UserPreferences

    @State private var viewModel: AnalyticsViewModel

    init(
        appState: AppState,
        courseRepository: any CourseRepositoryProtocol,
        semesterRepository: any SemesterRepositoryProtocol,
        readingRepository: any ReadingRepositoryProtocol,
        pdfProgressRepository: any PDFProgressRepositoryProtocol,
        flashcardRepository: any FlashcardRepositoryProtocol,
        activeRecallRepository: any ActiveRecallRepositoryProtocol,
        studySessionRepository: any StudySessionRepositoryProtocol,
        userPreferences: UserPreferences
    ) {
        self.appState = appState
        self.courseRepository = courseRepository
        self.semesterRepository = semesterRepository
        self.readingRepository = readingRepository
        self.pdfProgressRepository = pdfProgressRepository
        self.flashcardRepository = flashcardRepository
        self.activeRecallRepository = activeRecallRepository
        self.studySessionRepository = studySessionRepository
        self.userPreferences = userPreferences
        _viewModel = State(wrappedValue: AnalyticsViewModel(
            appState: appState,
            courseRepository: courseRepository,
            semesterRepository: semesterRepository,
            readingRepository: readingRepository,
            pdfProgressRepository: pdfProgressRepository,
            flashcardRepository: flashcardRepository,
            activeRecallRepository: activeRecallRepository,
            studySessionRepository: studySessionRepository,
            userPreferences: userPreferences
        ))
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        if let error = viewModel.loadError {
                            Text(error.message)
                                .foregroundStyle(.red)
                        }

                        gpaSection
                        studyTimeSection
                        sessionSection
                        flashcardSection
                        activeRecallSection
                        readingSection
                        chartsSection
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadAnalytics()
        }
    }

    // MARK: GPA (NTU 5.0 scale)

    private var gpaSection: some View {
        NavigationLink {
            GPADetailView(gpaSummary: viewModel.gpaSummary, semesterGPABreakdown: viewModel.semesterGPABreakdown)
        } label: {
            AnalyticsSectionCard(title: "GPA", icon: "graduationcap.fill", tint: .indigo) {
                VStack(alignment: .leading, spacing: 12) {
                    AnalyticsStatGrid(items: [
                        (formattedGPA(viewModel.gpaSummary.semesterGPA), viewModel.gpaSummary.semesterName ?? "This Semester", "calendar", .indigo),
                        (formattedGPA(viewModel.gpaSummary.cumulativeGPA), "Cumulative", "sum", .blue)
                    ])
                    Text("Stays blank until every course in that semester has a real Final Letter Grade set — no estimating.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 4) {
                        Text("View by Semester")
                        Image(systemName: "chevron.right")
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.indigo)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func formattedGPA(_ gpa: Double?) -> String {
        guard let gpa else { return "—" }
        return String(format: "%.2f", gpa)
    }

    // MARK: Section 1 — Study time + streaks

    private var studyTimeSection: some View {
        AnalyticsSectionCard(title: "Study Time", icon: "clock.fill", tint: .orange) {
            AnalyticsStatGrid(items: [
                (StudyTimeFormatter.label(minutes: viewModel.studyTimeSummary.todayMinutes), "Today", "clock.fill", .orange),
                (StudyTimeFormatter.label(minutes: viewModel.studyTimeSummary.weekMinutes), "This Week", "calendar", .blue),
                (StudyTimeFormatter.label(minutes: viewModel.studyTimeSummary.monthMinutes), "This Month", "calendar.badge.clock", .purple),
                ("\(viewModel.studyTimeSummary.currentStreak)d", "Current Streak", "flame.fill", .orange),
                ("\(viewModel.studyTimeSummary.longestStreak)d", "Longest Streak", "flame.fill", .red)
            ])
        }
    }

    // MARK: Section 5 — Study Sessions

    private var sessionSection: some View {
        AnalyticsSectionCard(title: "Study Sessions", icon: "timer", tint: .blue) {
            AnalyticsStatGrid(items: [
                (formattedMinutes(viewModel.sessionAnalytics.averageSessionMinutes), "Avg. Session", "clock.fill", .blue),
                (formattedMinutes(viewModel.sessionAnalytics.longestSessionMinutes), "Longest Session", "timer", .indigo),
                ("\(viewModel.sessionAnalytics.totalPomodoros)", "Pomodoros", "timer.circle.fill", .green),
                (viewModel.sessionAnalytics.mostStudiedCourseName ?? "—", "Most Studied", "book.closed.fill", .teal)
            ])
        }
    }

    // MARK: Section 3 — Flashcards

    private var flashcardSection: some View {
        AnalyticsSectionCard(title: "Flashcards", icon: "rectangle.stack.fill", tint: .blue) {
            AnalyticsStatGrid(items: [
                ("\(viewModel.flashcardAnalytics.cardsReviewed)", "Reviewed", "rectangle.stack.fill", .blue),
                ("\(viewModel.flashcardAnalytics.cardsDue)", "Due", "bell.fill", .orange),
                (formattedNumber(viewModel.flashcardAnalytics.averageEaseFactor), "Avg. Ease", "gauge", .purple),
                (formattedDays(viewModel.flashcardAnalytics.averageIntervalDays), "Avg. Interval", "calendar", .indigo),
                (formattedPercent(viewModel.flashcardAnalytics.retentionEstimatePercent), "Retention Est.", "chart.line.uptrend.xyaxis", .green)
            ])
            if viewModel.flashcardAnalytics.cardsReviewed > 0 {
                Text("Retention is based on each card's most recent rating, not a full review history.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: Section 4 — Active Recall

    private var activeRecallSection: some View {
        AnalyticsSectionCard(title: "Active Recall", icon: "brain.head.profile", tint: .purple) {
            AnalyticsStatGrid(items: [
                ("\(viewModel.activeRecallAnalytics.questionsAnswered)", "Answered", "brain.head.profile", .purple),
                (formattedPercent(viewModel.activeRecallAnalytics.successRatePercent), "Success Rate", "checkmark.circle.fill", .green),
                (formattedPercent(viewModel.activeRecallAnalytics.averageConfidencePercent), "Avg. Confidence", "gauge", .blue)
            ])
            ReviewHistoryChart(data: viewModel.reviewHistoryChart)
        }
    }

    // MARK: Section 2 — Reading

    private var readingSection: some View {
        AnalyticsSectionCard(title: "Reading", icon: "book.fill", tint: .green) {
            AnalyticsStatGrid(items: [
                ("\(viewModel.readingAnalytics.pagesRead)", "Pages Read", "doc.text.fill", .orange),
                ("\(viewModel.readingAnalytics.booksCompleted)", "Books Completed", "book.closed.fill", .teal),
                (formattedPagesPerHour(viewModel.readingAnalytics.averageReadingSpeedPagesPerHour), "Avg. Speed", "hare.fill", .green)
            ])
            ReadingProgressChart(data: viewModel.readingProgressByCourse)
        }
    }

    // MARK: Section 6 — Charts

    private var chartsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            AnalyticsSectionCard(title: "Daily Study Time", icon: "chart.bar.fill", tint: .indigo) {
                DailyStudyTimeChart(data: viewModel.dailyStudyTimeChart)
            }
            AnalyticsSectionCard(title: "Weekly Trend", icon: "chart.line.uptrend.xyaxis", tint: .teal) {
                WeeklyTrendChart(data: viewModel.weeklyTrendChart)
            }
            AnalyticsSectionCard(title: "Course Distribution", icon: "chart.pie.fill", tint: .pink) {
                CourseDistributionChart(data: viewModel.courseDistributionChart)
            }
            AnalyticsSectionCard(title: "Study Calendar", icon: "calendar", tint: .orange) {
                StudyCalendarMonthView(
                    month: viewModel.displayedMonth,
                    days: viewModel.calendarDays,
                    weekdayLabels: viewModel.weekdayLabels,
                    currentStreak: viewModel.studyTimeSummary.currentStreak,
                    monthMinutes: viewModel.monthStudyMinutes,
                    onPreviousMonth: { withAnimation(.easeInOut(duration: 0.25)) { viewModel.goToPreviousMonth() } },
                    onNextMonth: { withAnimation(.easeInOut(duration: 0.25)) { viewModel.goToNextMonth() } }
                )
                .animation(.easeInOut(duration: 0.25), value: viewModel.displayedMonth)
            }
        }
    }

    // MARK: Formatting helpers

    private func formattedMinutes(_ minutes: Double?) -> String {
        guard let minutes else { return "—" }
        return StudyTimeFormatter.label(minutes: minutes)
    }

    private func formattedNumber(_ value: Double?) -> String {
        guard let value else { return "—" }
        return String(format: "%.2f", value)
    }

    private func formattedDays(_ days: Double?) -> String {
        guard let days else { return "—" }
        return "\(Int(days.rounded()))d"
    }

    private func formattedPercent(_ percent: Double?) -> String {
        guard let percent else { return "—" }
        return "\(Int(percent.rounded()))%"
    }

    private func formattedPagesPerHour(_ value: Double?) -> String {
        guard let value else { return "—" }
        return String(format: "%.1f pg/hr", value)
    }
}

/// Shared card chrome for every Analytics section — a tinted-icon header
/// (matching Home/Course Page's `SectionHeaderLabel`) plus whatever content
/// (a stat grid, a chart, or both) each section provides.
private struct AnalyticsSectionCard<Content: View>: View {
    let title: String
    var icon: String = "chart.bar.fill"
    var tint: Color = .accentColor
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderLabel(title: title, icon: icon, tint: tint)
            content
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: StudyHubMetrics.cardCornerRadius))
        .studyHubCardShadow()
    }
}

/// A row of icon-topped stat tiles separated by dividers — matches Home's
/// Study Overview / the Course Page's stats card instead of the plain bare
/// number+label this used to be (the last place in the app still using
/// that older, icon-less style).
/// Not `private` — also reused by `CourseDetailView`'s stats row.
struct AnalyticsStatGrid: View {
    let items: [(value: String, label: String, icon: String, tint: Color)]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                if index > 0 {
                    Divider().frame(height: 44)
                }
                VStack(spacing: 4) {
                    Image(systemName: item.icon)
                        .font(.subheadline)
                        .foregroundStyle(item.tint.opacity(0.85))
                    Text(item.value)
                        .font(.system(.title3, design: .rounded).weight(.bold))
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .contentTransition(.numericText())
                    Text(item.label)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}
