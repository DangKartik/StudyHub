import SwiftUI

/// Shown once a Study Session ends (Phase 4.3, requirement 5). Purely a
/// display of what's already been stored onto `session` by
/// `StudySessionViewModel.endSession(completedPomodoros:)` — this view owns
/// nothing itself.
struct StudySessionSummaryView: View {
    let session: StudySession
    let onDone: () -> Void

    private var durationText: String {
        let totalMinutes = Int(session.duration) / 60
        if totalMinutes < 1 { return "Under a minute" }
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes) min"
    }

    private var completionMessage: String {
        let totalActions = session.flashcardsReviewedCount + session.questionsAnsweredCount + session.pagesReadCount
        return totalActions == 0
            ? "Every focused minute counts — nice work showing up."
            : "Great focus session! Keep up the momentum."
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.green)
                    .accessibilityHidden(true)

                Text("Session Complete")
                    .font(.title)
                    .fontWeight(.bold)

                Text(completionMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                VStack(spacing: 0) {
                    summaryRow(icon: "clock", label: "Duration", value: durationText)
                    Divider()
                    summaryRow(icon: "rectangle.stack", label: "Flashcards Reviewed", value: "\(session.flashcardsReviewedCount)")
                    Divider()
                    summaryRow(icon: "questionmark.circle", label: "Questions Answered", value: "\(session.questionsAnsweredCount)")
                    Divider()
                    summaryRow(icon: "doc.text", label: "Pages Read", value: "\(session.pagesReadCount)")
                }
                .padding(.vertical, 4)
                .background(.background, in: RoundedRectangle(cornerRadius: StudyHubMetrics.cardCornerRadius))
                .overlay(RoundedRectangle(cornerRadius: StudyHubMetrics.cardCornerRadius).stroke(.separator, lineWidth: 1))
                .padding(.horizontal)

                Spacer()

                Button("Done", action: onDone)
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.bottom)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationBarBackButtonHidden(true)
        }
    }

    private func summaryRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Label(label, systemImage: icon)
                .foregroundStyle(.primary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}
