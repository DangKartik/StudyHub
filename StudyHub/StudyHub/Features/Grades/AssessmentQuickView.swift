import SwiftUI

/// Reached by tapping an exam from Home's "Upcoming Exam(s)" card or the
/// Course Page's "Upcoming" card. Read-only, same as the `ExamQuickView`
/// this replaces — editing still happens from the course's own Grades tab.
struct AssessmentQuickView: View {
    let assessment: Assessment

    @Environment(\.dismiss) private var dismiss

    private var courseLabel: String {
        guard let course = assessment.course else { return "—" }
        return course.name.isEmpty ? course.courseCode : course.name
    }

    private var durationLabel: String? {
        guard assessment.duration > 0 else { return nil }
        let totalMinutes = Int(assessment.duration / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        switch (hours, minutes) {
        case (0, _): return "\(minutes)m"
        case (_, 0): return "\(hours)h"
        default: return "\(hours)h \(minutes)m"
        }
    }

    private var trimmedNotes: String {
        assessment.notes.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent("Title", value: assessment.title)
                    LabeledContent("Course", value: courseLabel)
                    LabeledContent("Date", value: assessment.date.formatted(date: .abbreviated, time: .shortened))
                    if !assessment.location.isEmpty {
                        LabeledContent("Location", value: assessment.location)
                    }
                    if assessment.weight > 0 {
                        LabeledContent("Weight", value: "\(assessment.weight.formatted())%")
                    }
                    if let durationLabel {
                        LabeledContent("Duration", value: durationLabel)
                    }
                    if let score = assessment.score {
                        LabeledContent("Score", value: "\(score.formatted()) / \(assessment.maximumScore.formatted())")
                    }
                } header: {
                    Label(assessment.kind.label, systemImage: assessment.kind.icon)
                }

                if !trimmedNotes.isEmpty {
                    Section {
                        Text(assessment.notes)
                            .foregroundStyle(.secondary)
                    } header: {
                        Label("Notes", systemImage: "text.alignleft")
                    }
                }
            }
            .navigationTitle(assessment.kind.label)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}
