import SwiftUI

struct SemesterFormView: View {
    let viewModel: SemesterViewModel

    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var startDate: Date = .now
    @State private var endDate: Date = .now
    @State private var selectedColor: String = SemesterFormView.colorPresets.first!.name

    private static let colorPresets: [(name: String, color: Color)] = [
        ("blue", .blue),
        ("green", .green),
        ("orange", .orange),
        ("purple", .purple),
        ("pink", .pink),
        ("gray", .gray)
    ]

    private var isEndDateValid: Bool {
        endDate >= startDate
    }

    private var canCreate: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && isEndDateValid
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Semester") {
                    TextField("Name", text: $name)
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)

                    if !isEndDateValid {
                        Text("End date must be on or after the start date.")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                Section("Color") {
                    Picker("Color", selection: $selectedColor) {
                        ForEach(Self.colorPresets, id: \.name) { preset in
                            Label {
                                Text(preset.name.capitalized)
                            } icon: {
                                Circle()
                                    .fill(preset.color)
                                    .frame(width: 16, height: 16)
                            }
                            .tag(preset.name)
                        }
                    }
                    .pickerStyle(.inline)
                }
            }
            .navigationTitle("New Semester")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        viewModel.createSemester(
                            name: name,
                            startDate: startDate,
                            endDate: endDate,
                            color: selectedColor
                        )
                        dismiss()
                    }
                    .disabled(!canCreate)
                }
            }
        }
    }
}
