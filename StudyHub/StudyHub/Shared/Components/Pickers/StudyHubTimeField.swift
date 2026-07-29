import SwiftUI

/// A compact, tappable time field that opens a floating Apple Calendar-style
/// wheel time picker (hour / minute / AM-PM columns) only while presented.
struct StudyHubTimeField: View {
    let label: String
    @Binding var time: Date

    @State private var isPresented = false

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.primary)
            Spacer()
            Button {
                isPresented = true
            } label: {
                Text(time.formatted(date: .omitted, time: .shortened))
                    .foregroundStyle(.secondary)
                    .frame(width: 90, alignment: .trailing)
            }
            .buttonStyle(.plain)
            .background(
                DirectionalPopoverAnchor(isPresented: $isPresented, arrowDirections: .up) {
                    DatePicker(label, selection: $time, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .padding()
                        .frame(width: 320, height: 220, alignment: .top)
                }
            )
        }
        .contentShape(Rectangle())
    }
}
