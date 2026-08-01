import SwiftUI

/// Dedicated Analytics dashboard (Phase 4.5) — entirely read-only, computed
/// fresh from existing repositories each time it appears. Reuses the
/// sidebar's existing `.statistics` destination, which had no real screen
/// behind it until now (same dead-stub shape `.resources` had before it was
/// removed).
struct AnalyticsView: View {
    let courseRepository: any CourseRepositoryProtocol
    let readingRepository: any ReadingRepositoryProtocol
    let pdfProgressRepository: any PDFProgressRepositoryProtocol
    let flashcardRepository: any FlashcardRepositoryProtocol
    let activeRecallRepository: any ActiveRecallRepositoryProtocol
    let studySessionRepository: any StudySessionRepositoryProtocol
    let userPreferences: UserPreferences

    @State private var viewModel: AnalyticsViewModel

    init(
        courseRepository: any CourseRepositoryProtocol,
        readingRepository: any ReadingRepositoryProtocol,
        pdfProgressRepository: any PDFProgressRepositoryProtocol,
        flashcardRepository: any FlashcardRepositoryProtocol,
        activeRecallRepository: any ActiveRecallRepositoryProtocol,
        studySessionRepository: any StudySessionRepositoryProtocol,
        userPreferences: UserPreferences
    ) {
        self.courseRepository = courseRepository
        self.readingRepository = readingRepository
        self.pdfProgressRepository = pdfProgressRepository
        self.flashcardRepository = flashcardRepository
        self.activeRecallRepository = activeRecallRepository
        self.studySessionRepository = studySessionRepository
        self.userPreferences = userPreferences
        _viewModel = State(wrappedValue: AnalyticsViewModel(
            courseRepository: courseRepository,
            readingRepository: readingRepository,
            pdfProgressRepository: pdfProgressRepository,
            flashcardRepository: flashcardRepository,
            activeRecallRepository: activeRecallRepository,
            studySessionRepository: studySessionRepository,
            userPreferences: userPreferences
        ))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                if let error = viewModel.loadError {
                    Text(error.message)
                        .foregroundStyle(.red)
                }

                studyTimeSection
                sessionSection
                flashcardSection
                activeRecallSection
                readingSection
                chartsSection
            }
            .padding()
        }
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadAnalytics()
        }
    }

    // MARK: Section 1 — Study time + streaks

    private var studyTimeSection: some View {
        AnalyticsSectionCard(title: "Study Time") {
            AnalyticsStatGrid(items: [
                ("Today", StudyTimeFormatter.label(minutes: viewModel.studyTimeSummary.todayMinutes)),
                ("This Week", StudyTimeFormatter.label(minutes: viewModel.studyTimeSummary.weekMinutes)),
                ("This Month", StudyTimeFormatter.label(minutes: viewModel.studyTimeSummary.monthMinutes)),
                ("Current Streak", "\(viewModel.studyTimeSummary.currentStreak)d"),
                ("Longest Streak", "\(viewModel.studyTimeSummary.longestStreak)d")
            ])
        }
    }

    // MARK: Section 5 — Study Sessions

    private var sessionSection: some View {
        AnalyticsSectionCard(title: "Study Sessions") {
            AnalyticsStatGrid(items: [
                ("Avg. Session", formattedMinutes(viewModel.sessionAnalytics.averageSessionMinutes)),
                ("Longest Session", formattedMinutes(viewModel.sessionAnalytics.longestSessionMinutes)),
                ("Pomodoros", "\(viewModel.sessionAnalytics.totalPomodoros)"),
                ("Most Studied", viewModel.sessionAnalytics.mostStudiedCourseName ?? "—")
            ])
        }
    }

    // MARK: Section 3 — Flashcards

    private var flashcardSection: some View {
        AnalyticsSectionCard(title: "Flashcards") {
            AnalyticsStatGrid(items: [
                ("Reviewed", "\(viewModel.flashcardAnalytics.cardsReviewed)"),
                ("Due", "\(viewModel.flashcardAnalytics.cardsDue)"),
                ("Avg. Ease", formattedNumber(viewModel.flashcardAnalytics.averageEaseFactor)),
                ("Avg. Interval", formattedDays(viewModel.flashcardAnalytics.averageIntervalDays)),
                ("Retention Est.", formattedPercent(viewModel.flashcardAnalytics.retentionEstimatePercent))
            ])
            if viewModel.flashcardAnalytics.cardsReviewed > 0 {
                Text("Retention is based on each card's most recent rating, not a full review history.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: Section 4 — Active Recall

    private var activeRecallSection: some View {
        AnalyticsSectionCard(title: "Active Recall") {
            AnalyticsStatGrid(items: [
                ("Answered", "\(viewModel.activeRecallAnalytics.questionsAnswered)"),
                ("Success Rate", formattedPercent(viewModel.activeRecallAnalytics.successRatePercent)),
                ("Avg. Confidence", formattedPercent(viewModel.activeRecallAnalytics.averageConfidencePercent))
            ])
            ReviewHistoryChart(data: viewModel.reviewHistoryChart)
        }
    }

    // MARK: Section 2 — Reading

    private var readingSection: some View {
        AnalyticsSectionCard(title: "Reading") {
            AnalyticsStatGrid(items: [
                ("Pages Read", "\(viewModel.readingAnalytics.pagesRead)"),
                ("Books Completed", "\(viewModel.readingAnalytics.booksCompleted)"),
                ("Avg. Speed", formattedPagesPerHour(viewModel.readingAnalytics.averageReadingSpeedPagesPerHour))
            ])
            ReadingProgressChart(data: viewModel.readingProgressByCourse)
        }
    }

    // MARK: Section 6 — Charts

    private var chartsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            AnalyticsSectionCard(title: "Daily Study Time") {
                DailyStudyTimeChart(data: viewModel.dailyStudyTimeChart)
            }
            AnalyticsSectionCard(title: "Weekly Trend") {
                WeeklyTrendChart(data: viewModel.weeklyTrendChart)
            }
            AnalyticsSectionCard(title: "Course Distribution") {
                CourseDistributionChart(data: viewModel.courseDistributionChart)
            }
            AnalyticsSectionCard(title: "Study Calendar") {
                StudyCalendarMonthView(
                    month: viewModel.displayedMonth,
                    days: viewModel.calendarDays,
                    weekdayLabels: viewModel.weekdayLabels,
                    currentStreak: viewModel.studyTimeSummary.currentStreak,
                    monthMinutes: viewModel.monthStudyMinutes,
                    onPreviousMonth: { viewModel.goToPreviousMonth() },
                    onNextMonth: { viewModel.goToNextMonth() }
                )
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

/// Shared card chrome for every Analytics section — a title plus whatever
/// content (a stat grid, a chart, or both) each section provides.
private struct AnalyticsSectionCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3.bold())
            content
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

/// A wrapping row of (label, value) stat tiles — used by every section's
/// headline numbers before its chart (if any).
private struct AnalyticsStatGrid: View {
    let items: [(String, String)]

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 12)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(items, id: \.0) { item in
                VStack(spacing: 2) {
                    Text(item.1)
                        .font(.title3.bold())
                    Text(item.0)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}
