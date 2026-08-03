import SwiftUI

struct CourseFormView: View {
    let viewModel: CoursesViewModel
    let course: Course?

    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var courseCode: String = ""
    @State private var instructor: String = ""
    @State private var email: String = ""
    @State private var secondInstructor: String = ""
    @State private var secondInstructorEmail: String = ""
    @State private var credits: Int = 0
    @State private var colorSelection: ColorSelection = .preset("blue")
    @State private var customColor: Color = .blue
    @State private var isShowingCustomColorPicker = false
    @State private var selectedSemester: Semester?

    private enum ColorSelection: Hashable {
        case preset(String)
        case custom
    }

    private static let presetColors: [(name: String, label: String, color: Color)] = [
        ("red", "Red", .red),
        ("orange", "Orange", .orange),
        ("yellow", "Yellow", .yellow),
        ("green", "Green", .green),
        ("blue", "Blue", .blue),
        ("purple", "Purple", .purple),
        ("brown", "Brown", .brown)
    ]

    private var isEditing: Bool {
        course != nil
    }

    private var isEmailValid: Bool {
        email.isEmpty || email.isValidEmail
    }

    private var isSecondEmailValid: Bool {
        secondInstructorEmail.isEmpty || secondInstructorEmail.isValidEmail
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !courseCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        isEmailValid &&
        isSecondEmailValid &&
        (!isEditing || selectedSemester != nil)
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
                    TextField("Course Code", text: $courseCode)
                    if isEditing {
                        Picker("Semester", selection: $selectedSemester) {
                            ForEach(viewModel.semesters, id: \.id) { semester in
                                Text(semester.name).tag(Optional(semester))
                            }
                        }
                    } else {
                        LabeledContent("Semester", value: viewModel.activeSemester?.name ?? "No Semester")
                    }
                    Stepper("Credits: \(credits)", value: $credits, in: 0...12)
                } header: {
                    Label("Course", systemImage: "book.closed.fill")
                }

                Section {
                    TextField("Name", text: $instructor)
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    if !isEmailValid {
                        Text("Enter a valid email address.")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                } header: {
                    Label("Professor 1", systemImage: "person.fill")
                }

                Section {
                    TextField("Name", text: $secondInstructor)
                    TextField("Email", text: $secondInstructorEmail)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    if !isSecondEmailValid {
                        Text("Enter a valid email address.")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                } header: {
                    Label("Professor 2", systemImage: "person.fill")
                }

                Section {
                    // A grid of tappable swatches, matching the same "tag
                    // color" picker pattern Reminders/Calendar use, instead
                    // of a checklist of circle+label rows — colors are
                    // recognized faster by shape/hue than by reading down
                    // a list of color names.
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4), spacing: 16) {
                        ForEach(Self.presetColors, id: \.name) { preset in
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
                    Label("Course Color", systemImage: "paintpalette.fill")
                }
            }
            .navigationTitle(isEditing ? "Edit Course" : "New Course")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let course {
                            guard let selectedSemester else { return }
                            viewModel.updateCourse(
                                course,
                                name: name,
                                courseCode: courseCode,
                                instructor: instructor,
                                email: email,
                                secondInstructor: secondInstructor,
                                secondInstructorEmail: secondInstructorEmail,
                                credits: credits,
                                color: storedColor,
                                semester: selectedSemester
                            )
                        } else {
                            viewModel.createCourse(
                                name: name,
                                courseCode: courseCode,
                                instructor: instructor,
                                email: email,
                                secondInstructor: secondInstructor,
                                secondInstructorEmail: secondInstructorEmail,
                                credits: credits,
                                color: storedColor
                            )
                        }
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                if let course {
                    name = course.name
                    courseCode = course.courseCode
                    instructor = course.instructor
                    email = course.email
                    secondInstructor = course.secondInstructor
                    secondInstructorEmail = course.secondInstructorEmail
                    credits = course.credits
                    selectedSemester = course.semester

                    if let presetName = Self.presetColors.first(where: { $0.name == course.courseColor })?.name {
                        colorSelection = .preset(presetName)
                    } else {
                        colorSelection = .custom
                        customColor = Color.courseColor(from: course.courseColor)
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
