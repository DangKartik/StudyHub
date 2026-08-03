import SwiftUI
import Charts

/// Every chart in this phase uses Swift Charts only — no third-party chart
/// library, per Phase 4.5's explicit requirement.

struct DailyStudyTimeChart: View {
    let data: [DailyDataPoint]

    /// Once the busiest day in view is an hour or more, minutes stop being
    /// a readable unit for the whole chart — switch every value (and the
    /// axis label) to hours together, rather than per-bar.
    private var useHours: Bool {
        (data.map(\.minutes).max() ?? 0) >= 60
    }

    var body: some View {
        Chart(data) { point in
            BarMark(
                x: .value("Date", point.date, unit: .day),
                y: .value("Time", useHours ? point.minutes / 60 : point.minutes)
            )
            .foregroundStyle(Color.accentColor)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 7)) { value in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
            }
        }
        .chartYAxisLabel(useHours ? "Hours" : "Minutes")
        .frame(height: 180)
    }
}

struct WeeklyTrendChart: View {
    let data: [WeeklyDataPoint]

    private var useHours: Bool {
        (data.map(\.minutes).max() ?? 0) >= 60
    }

    var body: some View {
        Chart(data) { point in
            LineMark(
                x: .value("Week", point.weekStart, unit: .weekOfYear),
                y: .value("Time", useHours ? point.minutes / 60 : point.minutes)
            )
            .symbol(.circle)
            .foregroundStyle(Color.accentColor)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .weekOfYear, count: 2)) { value in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
            }
        }
        .chartYAxisLabel(useHours ? "Hours" : "Minutes")
        .frame(height: 180)
    }
}

/// Top 5 courses by total study time, with the rest folded into "Other" so
/// the donut stays readable regardless of how many courses exist.
struct CourseDistributionChart: View {
    let data: [CourseDistributionPoint]

    private var displayData: [CourseDistributionPoint] {
        guard data.count > 5 else { return data }
        let top = Array(data.prefix(5))
        let otherMinutes = data.dropFirst(5).reduce(0.0) { $0 + $1.minutes }
        return top + [CourseDistributionPoint(courseName: "Other", minutes: otherMinutes)]
    }

    /// Swift Charts' automatic legend (from `.foregroundStyle(by:)`) has no
    /// supported way to enlarge its text — a `.font()` on the `Chart`
    /// itself is silently ignored by the legend specifically. Assigning
    /// colors explicitly here, instead of letting Charts pick them, means
    /// a plain custom `Text` legend below can use the exact same colors
    /// and any font size we want.
    private static let palette: [Color] = [.blue, .green, .orange, .purple, .pink, .teal, .indigo, .red]

    private func color(for index: Int) -> Color {
        Self.palette[index % Self.palette.count]
    }

    var body: some View {
        if data.isEmpty {
            StudyHubEmptyState(icon: "chart.pie", title: "No Study Time Yet", message: "Complete a Study Session to see this chart.")
        } else {
            VStack(spacing: 16) {
                Chart(Array(displayData.enumerated()), id: \.element.id) { index, point in
                    SectorMark(
                        angle: .value("Minutes", point.minutes),
                        innerRadius: .ratio(0.5),
                        angularInset: 1.5
                    )
                    .foregroundStyle(color(for: index))
                    .cornerRadius(4)
                }
                .frame(height: 220)
                .chartLegend(.hidden)

                TagFlowLayout(spacing: 12) {
                    ForEach(Array(displayData.enumerated()), id: \.element.id) { index, point in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(color(for: index))
                                .frame(width: 10, height: 10)
                            Text(point.courseName)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
        }
    }
}

/// Grouped bars — Flashcards vs Active Recall reviews per day.
struct ReviewHistoryChart: View {
    let data: [ReviewHistoryPoint]

    var body: some View {
        Chart(data) { point in
            BarMark(
                x: .value("Date", point.date, unit: .day),
                y: .value("Reviews", point.flashcardReviews)
            )
            .foregroundStyle(by: .value("Type", "Flashcards"))
            .position(by: .value("Type", "Flashcards"))

            BarMark(
                x: .value("Date", point.date, unit: .day),
                y: .value("Reviews", point.questionReviews)
            )
            .foregroundStyle(by: .value("Type", "Active Recall"))
            .position(by: .value("Type", "Active Recall"))
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 7)) { value in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
            }
        }
        .chartYAxisLabel("Reviews")
        .frame(height: 180)
    }
}

struct ReadingProgressChart: View {
    let data: [ReadingProgressPoint]

    var body: some View {
        if data.isEmpty {
            StudyHubEmptyState(icon: "book", title: "No Reading Progress Yet", message: "Open a PDF to start tracking progress.")
        } else {
            Chart(data) { point in
                BarMark(
                    x: .value("Progress", point.percent),
                    y: .value("Course", point.courseName)
                )
                .foregroundStyle(Color.accentColor)
                .annotation(position: .trailing) {
                    Text("\(Int(point.percent))%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            // A 100%-complete course's bar would otherwise reach the exact
            // right edge of the plot area, leaving its "100%" annotation
            // nowhere to draw but off the edge of the screen — extra
            // headroom in the domain keeps every bar (and its label) short
            // of that edge instead of clipping it.
            .chartXScale(domain: 0...115)
            .frame(height: CGFloat(data.count) * 36 + 20)
        }
    }
}

/// A real calendar-month grid (Study Session Analytics' "daily study
/// heatmap") — deliberately a plain SwiftUI `LazyVGrid`, not Swift Charts:
/// a genuine month layout with day numbers inside each cell isn't really a
/// "chart," the same way Apple's own Fitness/Health calendar views aren't
/// built with Charts either. Color intensity per day = minutes studied
/// that day; a thin orange ring marks days that are part of the current
/// streak; today gets an accent-colored ring. Month navigation is handled
/// by the caller (`AnalyticsView`) via the three closures.
struct StudyCalendarMonthView: View {
    let month: Date
    let days: [CalendarDayCell]
    let weekdayLabels: [String]
    let currentStreak: Int
    let monthMinutes: Int
    let onPreviousMonth: () -> Void
    let onNextMonth: () -> Void

    private static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    private var monthTitle: String {
        Self.monthFormatter.string(from: month)
    }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            weekdayHeader
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(days) { cell in
                    dayCell(cell)
                }
            }
        }
    }

    private var header: some View {
        HStack {
            navButton(systemImage: "chevron.left", action: onPreviousMonth)

            Spacer()

            VStack(spacing: 3) {
                HStack(spacing: 6) {
                    Text(monthTitle)
                        .font(.title3.weight(.semibold))
                    if currentStreak > 0 {
                        streakBadge
                    }
                }
                Text("\(StudyTimeFormatter.label(minutes: monthMinutes)) studied")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            navButton(systemImage: "chevron.right", action: onNextMonth)
        }
    }

    private var streakBadge: some View {
        HStack(spacing: 3) {
            Image(systemName: "flame.fill")
                .font(.caption2)
            Text("\(currentStreak)")
                .font(.caption.weight(.bold))
        }
        .foregroundStyle(.orange)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(Color.orange.opacity(0.14), in: Capsule())
    }

    private func navButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(width: 30, height: 30)
                .background(Color(uiColor: .systemGray6), in: Circle())
        }
        .buttonStyle(.plain)
    }

    private var weekdayHeader: some View {
        HStack(spacing: 6) {
            ForEach(weekdayLabels, id: \.self) { label in
                Text(label.uppercased())
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    /// No study-time intensity fill at all — just three states: today (a
    /// solid filled circle with its number), a streak day (🔥 in a dashed
    /// ring), or a plain number with no background otherwise. Today wins
    /// over the streak look even if it's also part of the streak, since
    /// its own solid-circle treatment already reads as "you are here."
    @ViewBuilder
    private func dayCell(_ cell: CalendarDayCell) -> some View {
        if let dayNumber = cell.dayNumber {
            ZStack {
                if cell.isToday {
                    Circle()
                        .fill(Color.primary.opacity(0.85))
                } else if cell.isInCurrentStreak {
                    Circle()
                        .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [2, 2]))
                        .foregroundStyle(Color.orange.opacity(0.7))
                }

                if cell.isToday {
                    Text("\(dayNumber)")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color(uiColor: .systemBackground))
                } else if cell.isInCurrentStreak {
                    Text("🔥")
                        .font(.system(size: 16))
                } else {
                    Text("\(dayNumber)")
                        .font(.system(size: 15))
                        .foregroundStyle(.primary)
                }
            }
            .frame(height: 42)
        } else {
            Color.clear.frame(height: 42)
        }
    }
}
