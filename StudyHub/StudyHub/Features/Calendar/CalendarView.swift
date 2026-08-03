import SwiftUI

/// The sidebar's Calendar page — a month grid across the active semester's
/// courses, aggregating Lectures/Assignments/Exams+Quizzes/Readings onto
/// their real dates. Read-only (see `CalendarViewModel`'s doc comment):
/// selecting a day shows that day's items below the grid, tinted and iconed
/// by type, same visual language as the rest of the app's summary rows.
struct CalendarView: View {
    let appState: AppState
    let courseRepository: any CourseRepositoryProtocol
    let assignmentRepository: any AssignmentRepositoryProtocol
    let readingRepository: any ReadingRepositoryProtocol
    let lectureRepository: any LectureRepositoryProtocol
    let userPreferences: UserPreferences

    @State private var viewModel: CalendarViewModel
    @State private var visibleMonth: Date = Calendar.current.startOfDay(for: .now)
    @State private var selectedDay: Date = Calendar.current.startOfDay(for: .now)

    private static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter
    }()

    init(
        appState: AppState,
        courseRepository: any CourseRepositoryProtocol,
        assignmentRepository: any AssignmentRepositoryProtocol,
        readingRepository: any ReadingRepositoryProtocol,
        lectureRepository: any LectureRepositoryProtocol,
        userPreferences: UserPreferences
    ) {
        self.appState = appState
        self.courseRepository = courseRepository
        self.assignmentRepository = assignmentRepository
        self.readingRepository = readingRepository
        self.lectureRepository = lectureRepository
        self.userPreferences = userPreferences
        _viewModel = State(wrappedValue: CalendarViewModel(
            appState: appState,
            courseRepository: courseRepository,
            assignmentRepository: assignmentRepository,
            readingRepository: readingRepository,
            lectureRepository: lectureRepository
        ))
    }

    private var calendar: Calendar {
        userPreferences.calendar
    }

    var body: some View {
        Group {
            if !viewModel.hasActiveSemester {
                StudyHubEmptyState(
                    icon: "calendar.badge.exclamationmark",
                    title: "No Active Semester",
                    message: "Set an active semester to see your calendar."
                )
            } else {
                content
            }
        }
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Today") {
                    let today = Calendar.current.startOfDay(for: .now)
                    visibleMonth = today
                    selectedDay = today
                }
            }
        }
        .onAppear {
            viewModel.load()
        }
        .onReceive(NotificationCenter.default.publisher(for: .readingsDidChange)) { _ in
            viewModel.load()
        }
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                monthHeader
                weekdayHeader
                monthGrid
                Divider()
                agenda
            }
            .padding(20)
            .frame(maxWidth: 700)
            .frame(maxWidth: .infinity)
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

    private var monthHeader: some View {
        HStack {
            Button {
                shiftMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(Self.monthFormatter.string(from: visibleMonth))
                .font(.title2.weight(.bold))
            Spacer()
            Button {
                shiftMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
    }

    private var weekdayHeader: some View {
        let symbols = orderedWeekdaySymbols
        return HStack {
            ForEach(symbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var monthGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 8) {
            ForEach(daysInGrid, id: \.self) { day in
                if let day {
                    dayCell(day)
                } else {
                    Color.clear.frame(height: 44)
                }
            }
        }
    }

    private func dayCell(_ day: Date) -> some View {
        let isSelected = calendar.isDate(day, inSameDayAs: selectedDay)
        let isToday = calendar.isDateInToday(day)
        let items = viewModel.items(on: day)
        let dayNumber = calendar.component(.day, from: day)

        return Button {
            selectedDay = day
        } label: {
            VStack(spacing: 4) {
                Text("\(dayNumber)")
                    .font(.subheadline.weight(isToday ? .bold : .regular))
                    .foregroundStyle(isSelected ? .white : (isToday ? Color.accentColor : .primary))
                    .frame(width: 28, height: 28)
                    .background(isSelected ? Color.accentColor : Color.clear, in: Circle())
                    .overlay(
                        Circle().strokeBorder(isToday && !isSelected ? Color.accentColor : .clear, lineWidth: 1)
                    )

                HStack(spacing: 2) {
                    ForEach(dotTints(for: items), id: \.self) { tint in
                        Circle().fill(tint).frame(width: 4, height: 4)
                    }
                }
                .frame(height: 4)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(Self.dayFormatter.string(from: day)), \(items.count) item\(items.count == 1 ? "" : "s")")
    }

    /// Up to 3 dots, one per distinct item type present that day — avoids a
    /// packed day with 5 assignments turning into 5 dots that just read as
    /// visual noise.
    private func dotTints(for items: [CalendarItem]) -> [Color] {
        var seen: Set<String> = []
        var tints: [Color] = []
        for item in items {
            guard tints.count < 3, !seen.contains(item.typeLabel) else { continue }
            seen.insert(item.typeLabel)
            tints.append(item.tint)
        }
        return tints
    }

    private var agenda: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Self.dayFormatter.string(from: selectedDay))
                .font(.headline)

            let items = viewModel.items(on: selectedDay).sorted { $0.date < $1.date }
            if items.isEmpty {
                Text("Nothing on this day.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        if index > 0 { Divider().padding(.leading, 52) }
                        CalendarItemRow(item: item)
                    }
                }
                .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: StudyHubMetrics.cardCornerRadius))
                .studyHubCardShadow()
            }
        }
    }

    private func shiftMonth(by value: Int) {
        visibleMonth = calendar.date(byAdding: .month, value: value, to: visibleMonth) ?? visibleMonth
    }

    /// Weekday symbols reordered to start on whichever day
    /// `userPreferences.weekStartsOnMonday` puts first — same setting the
    /// rest of the app's "This Week" grouping already respects.
    private var orderedWeekdaySymbols: [String] {
        let symbols = calendar.shortWeekdaySymbols
        let offset = calendar.firstWeekday - 1
        return Array(symbols[offset...] + symbols[..<offset])
    }

    /// Every day cell for the visible month, padded with `nil` leading
    /// placeholders so day 1 lands under the correct weekday column.
    private var daysInGrid: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: visibleMonth),
              let firstDayRange = calendar.range(of: .day, in: .month, for: visibleMonth) else { return [] }

        let firstOfMonth = monthInterval.start
        let firstWeekdayOfMonth = calendar.component(.weekday, from: firstOfMonth)
        let leadingBlanks = (firstWeekdayOfMonth - calendar.firstWeekday + 7) % 7

        var days: [Date?] = Array(repeating: nil, count: leadingBlanks)
        for dayOffset in firstDayRange {
            if let date = calendar.date(byAdding: .day, value: dayOffset - 1, to: firstOfMonth) {
                days.append(date)
            }
        }
        return days
    }
}

private struct CalendarItemRow: View {
    let item: CalendarItem

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(item.tint)
                .frame(width: 36, height: 36)
                .background(item.tint.opacity(0.14), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.subheadline.weight(.semibold))
                HStack(spacing: 6) {
                    Text(item.typeLabel)
                    if let courseLabel = item.courseLabel {
                        Text("· \(courseLabel)")
                    }
                    if case .reading = item {
                        // Readings only carry a due date, no time.
                    } else {
                        Text("· \(Self.timeFormatter.string(from: item.date))")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            }

            Spacer()
        }
        .padding(12)
        .accessibilityElement(children: .combine)
    }
}
