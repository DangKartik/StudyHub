import SwiftUI

/// Reached by tapping the GPA card on Analytics — the summary card only has
/// room for one number per GPA kind, so this is where every semester's own
/// GPA lives, most recent first.
struct GPADetailView: View {
    let gpaSummary: GPASummary
    let semesterGPABreakdown: [SemesterGPARow]

    var body: some View {
        List {
            Section {
                LabeledContent("Cumulative GPA", value: formattedGPA(gpaSummary.cumulativeGPA))
            } footer: {
                Text("Cumulative only pools in semesters that are themselves fully graded — a semester still in progress doesn't contribute a partial number to it.")
            }

            Section("By Semester") {
                if semesterGPABreakdown.isEmpty {
                    Text("No semesters yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(semesterGPABreakdown) { row in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text(row.name)
                                        .font(.headline)
                                    if row.isActive {
                                        Text("Current")
                                            .font(.caption2.weight(.semibold))
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, StudyHubMetrics.badgeHorizontalPadding)
                                            .padding(.vertical, StudyHubMetrics.badgeVerticalPadding)
                                            .background(Color.indigo, in: Capsule())
                                    }
                                }
                                if row.gpa == nil {
                                    Text("Not fully graded yet")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text("\(row.credits) credits")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            Text(formattedGPA(row.gpa))
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(row.gpa == nil ? .secondary : .primary)
                        }
                    }
                }
            }
        }
        .navigationTitle("GPA")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func formattedGPA(_ gpa: Double?) -> String {
        guard let gpa else { return "—" }
        return String(format: "%.2f", gpa)
    }
}
