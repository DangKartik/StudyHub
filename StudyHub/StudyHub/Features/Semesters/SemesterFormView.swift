import SwiftUI

struct SemesterFormView: View {
    let viewModel: SemesterViewModel
    let semester: Semester?

    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var startDate: Date = .now
    @State private var endDate: Date = .now
    @State private var colorSelection: ColorSelection = .preset(SemesterFormView.colorPresets.first!.name)
    @State private var customColor: Color = .blue
    @State private var showCustomColorGrid = false

    private enum ColorSelection: Hashable {
        case preset(String)
        case custom
    }

    private static let colorPresets: [(name: String, color: Color)] = [
        ("blue", .blue),
        ("green", .green),
        ("orange", .orange),
        ("purple", .purple),
        ("pink", .pink),
        ("gray", .gray)
    ]

    private var isEditing: Bool {
        semester != nil
    }

    private var isEndDateValid: Bool {
        endDate >= startDate
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && isEndDateValid
    }

    private var storedColor: String {
        switch colorSelection {
        case .preset(let name):
            return name
        case .custom:
            return customColor.hexString
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Semester") {
                    TextField("Name", text: $name)
                    StudyHubDateField(label: "Start Date", date: $startDate)
                    StudyHubDateField(label: "End Date", date: $endDate)

                    if !isEndDateValid {
                        Text("End date must be on or after the start date.")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                Section("Color") {
                    ForEach(Self.colorPresets, id: \.name) { preset in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(preset.color)
                                .frame(width: 20, height: 20)
                            Text(preset.name.capitalized)
                            Spacer()
                            if colorSelection == .preset(preset.name) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            colorSelection = .preset(preset.name)
                        }
                    }

                    HStack(spacing: 12) {
                        if colorSelection == .custom {
                            Circle()
                                .fill(customColor)
                                .frame(width: 20, height: 20)
                        } else {
                            Image(systemName: "paintpalette.fill")
                                .foregroundStyle(.secondary)
                                .frame(width: 20, height: 20)
                        }
                        Text("Custom...")
                        Spacer()
                        if colorSelection == .custom {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        colorSelection = .custom
                        showCustomColorGrid = true
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Semester" : "New Semester")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let semester {
                            viewModel.updateSemester(
                                semester,
                                name: name,
                                startDate: startDate,
                                endDate: endDate,
                                color: storedColor
                            )
                        } else {
                            viewModel.createSemester(
                                name: name,
                                startDate: startDate,
                                endDate: endDate,
                                color: storedColor
                            )
                        }
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
            .sheet(isPresented: $showCustomColorGrid) {
                CustomColorGridView(selectedColor: $customColor)
            }
            .onAppear {
                if let semester {
                    name = semester.name
                    startDate = semester.startDate
                    endDate = semester.endDate

                    if let presetName = Self.colorPresets.first(where: { $0.name == semester.color })?.name {
                        colorSelection = .preset(presetName)
                    } else {
                        colorSelection = .custom
                        customColor = Color.courseColor(from: semester.color)
                    }
                }
            }
        }
    }
}
