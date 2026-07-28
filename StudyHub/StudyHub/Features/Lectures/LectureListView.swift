import SwiftUI

struct LectureListView: View {
    @State private var viewModel: LectureViewModel
    @State private var activeSheet: LectureSheet?

    init(course: Course, lectureRepository: any LectureRepositoryProtocol) {
        _viewModel = State(wrappedValue: LectureViewModel(
            course: course,
            lectureRepository: lectureRepository
        ))
    }

    var body: some View {
        Group {
            if viewModel.lectures.isEmpty {
                StudyHubEmptyState(
                    icon: "calendar.badge.plus",
                    title: "No Lectures Yet",
                    message: "Add lectures to organize your course schedule."
                )
            } else {
                list
            }
        }
        .navigationTitle("Lectures")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    activeSheet = .create
                } label: {
                    Label("Add Lecture", systemImage: "plus")
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .create:
                LectureFormView(viewModel: viewModel, lecture: nil)
            case .edit(let lecture):
                LectureFormView(viewModel: viewModel, lecture: lecture)
            }
        }
        .onAppear {
            viewModel.loadLectures()
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

            ForEach(viewModel.lectures, id: \.id) { lecture in
                LectureRowView(lecture: lecture)
                    .onTapGesture {
                        activeSheet = .edit(lecture)
                    }
                    .swipeActions(edge: .trailing) {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            viewModel.deleteLecture(lecture)
                        }
                    }
            }
        }
        .listStyle(.insetGrouped)
    }
}

private enum LectureSheet: Identifiable {
    case create
    case edit(Lecture)

    var id: String {
        switch self {
        case .create: return "create"
        case .edit(let lecture): return lecture.id.uuidString
        }
    }
}

private struct LectureRowView: View {
    let lecture: Lecture

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(lecture.topic)
                .font(.headline)
            HStack(spacing: 6) {
                Text(lecture.date.formatted(date: .abbreviated, time: .omitted))
                if !lecture.location.isEmpty {
                    Text("· \(lecture.location)")
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(lecture.topic). \(lecture.date.formatted(date: .abbreviated, time: .omitted)).")
    }
}
