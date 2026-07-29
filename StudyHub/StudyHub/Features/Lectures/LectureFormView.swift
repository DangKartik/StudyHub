import SwiftUI

struct LectureFormView: View {
    let viewModel: LectureViewModel
    let lecture: Lecture?

    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var topic: String = ""
    @State private var date: Date = .now
    @State private var startTime: Date = .now
    @State private var endTime: Date = .now
    @State private var location: String = ""
    @State private var summary: String = ""

    private var isEditing: Bool {
        lecture != nil
    }

    private var canSave: Bool {
        !topic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Lecture") {
                    TextField("Title", text: $title)
                    TextField("Topic", text: $topic)
                    StudyHubDateField(label: "Date", date: $date)
                    StudyHubTimeField(label: "Start Time", time: $startTime)
                    StudyHubTimeField(label: "End Time", time: $endTime)
                    TextField("Location", text: $location)
                }

                Section("Summary") {
                    TextField("Summary", text: $summary, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(isEditing ? "Edit Lecture" : "New Lecture")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let lecture {
                            viewModel.updateLecture(
                                lecture,
                                title: title,
                                topic: topic,
                                date: date,
                                startTime: startTime,
                                endTime: endTime,
                                location: location,
                                summary: summary
                            )
                        } else {
                            viewModel.createLecture(
                                title: title,
                                topic: topic,
                                date: date,
                                startTime: startTime,
                                endTime: endTime,
                                location: location,
                                summary: summary
                            )
                        }
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                if let lecture {
                    title = lecture.title
                    topic = lecture.topic
                    date = lecture.date
                    startTime = lecture.startTime
                    endTime = lecture.endTime
                    location = lecture.location
                    summary = lecture.summary
                }
            }
        }
    }
}
