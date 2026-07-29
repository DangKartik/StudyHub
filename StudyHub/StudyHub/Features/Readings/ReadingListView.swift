import SwiftUI

struct ReadingListView: View {
    @State private var viewModel: ReadingViewModel
    @State private var activeSheet: ReadingSheet?

    init(course: Course, readingRepository: any ReadingRepositoryProtocol) {
        _viewModel = State(wrappedValue: ReadingViewModel(
            course: course,
            readingRepository: readingRepository
        ))
    }

    var body: some View {
        Group {
            if viewModel.readings.isEmpty {
                StudyHubEmptyState(
                    icon: "book",
                    title: "No Readings Yet",
                    message: "Add readings to track your course material."
                )
            } else {
                list
            }
        }
        .navigationTitle("Readings")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    activeSheet = .create
                } label: {
                    Label("Add Reading", systemImage: "plus")
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .create:
                ReadingFormView(viewModel: viewModel, reading: nil)
            case .edit(let reading):
                ReadingFormView(viewModel: viewModel, reading: reading)
            }
        }
        .onAppear {
            viewModel.loadReadings()
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

            ForEach(viewModel.readings, id: \.id) { reading in
                ReadingRowView(reading: reading)
                    .onTapGesture {
                        activeSheet = .edit(reading)
                    }
                    .swipeActions(edge: .trailing) {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            viewModel.deleteReading(reading)
                        }
                    }
            }
        }
        .listStyle(.insetGrouped)
    }
}

private enum ReadingSheet: Identifiable {
    case create
    case edit(Reading)

    var id: String {
        switch self {
        case .create: return "create"
        case .edit(let reading): return reading.id.uuidString
        }
    }
}

private struct ReadingRowView: View {
    let reading: Reading

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(reading.title)
                .font(.headline)

            if !reading.author.isEmpty {
                Text(reading.author)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 6) {
                if let progressPercent {
                    Text("\(progressPercent)% Complete")
                }
                if let dueDate = reading.dueDate {
                    Text("· Due \(dueDate.formatted(date: .abbreviated, time: .omitted))")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(reading.title)." +
            (reading.author.isEmpty ? "" : " \(reading.author).") +
            (progressPercent.map { " \($0) percent complete." } ?? "") +
            (reading.dueDate.map { " Due \($0.formatted(date: .abbreviated, time: .omitted))." } ?? "")
        )
    }

    private var progressPercent: Int? {
        guard reading.pageCount > 0 else { return nil }
        return Int((Double(reading.currentPage) / Double(reading.pageCount) * 100).rounded())
    }
}
