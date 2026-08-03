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
    @State private var isShowingCustomColorPicker = false

    private enum ColorSelection: Hashable {
        case preset(String)
        case custom
    }

    private static let colorPresets: [(name: String, label: String, color: Color)] = [
        ("blue", "Blue", .blue),
        ("green", "Green", .green),
        ("orange", "Orange", .orange),
        ("purple", "Purple", .purple),
        ("pink", "Pink", .pink),
        ("gray", "Gray", .gray)
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
                Section {
                    TextField("Name", text: $name)
                    StudyHubDateField(label: "Start Date", date: $startDate)
                    StudyHubDateField(label: "End Date", date: $endDate)

                    if !isEndDateValid {
                        Text("End date must be on or after the start date.")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                } header: {
                    Label("Semester", systemImage: "calendar")
                }

                Section {
                    // Same tappable swatch-grid pattern as Course Color,
                    // instead of the checklist-of-rows this used to be —
                    // one shared "how do you pick a color" language across
                    // the app rather than each form inventing its own.
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4), spacing: 16) {
                        ForEach(Self.colorPresets, id: \.name) { preset in
                            colorSwatch(preset.color, isSelected: colorSelection == .preset(preset.name)) {
                                colorSelection = .preset(preset.name)
                            }
                            .accessibilityLabel(preset.label)
                        }

                        Button {
                            colorSelection = .custom
                            isShowingCustomColorPicker = true
                        } label: {
                            ZStack {
                                if colorSelection == .custom {
                                    Circle().fill(customColor)
                                } else {
                                    MulticolorSwatchIcon()
                                }
                                if colorSelection == .custom {
                                    Image(systemName: "checkmark")
                                        .font(.subheadline.weight(.bold))
                                        .foregroundStyle(.white)
                                        .shadow(color: .black.opacity(0.35), radius: 1)
                                }
                            }
                            .frame(width: 36, height: 36)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Custom Color")
                        .popover(isPresented: $isShowingCustomColorPicker) {
                            CustomColorPickerPanel(selectedColor: $customColor)
                                .padding()
                                .frame(width: 220, height: 220)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Label("Color", systemImage: "paintpalette.fill")
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

    private func colorSwatch(_ color: Color, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Circle().fill(color)
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.35), radius: 1)
                }
            }
            .frame(width: 36, height: 36)
        }
        .buttonStyle(.plain)
    }
}
