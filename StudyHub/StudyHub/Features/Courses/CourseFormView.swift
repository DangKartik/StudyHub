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
    @State private var showCustomColorGrid = false
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
                Section("Course") {
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
                }

                Section("Professor 1") {
                    TextField("Name", text: $instructor)
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    if !isEmailValid {
                        Text("Enter a valid email address.")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                Section("Professor 2") {
                    TextField("Name", text: $secondInstructor)
                    TextField("Email", text: $secondInstructorEmail)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    if !isSecondEmailValid {
                        Text("Enter a valid email address.")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                Section("Course Color") {
                    ForEach(Self.presetColors, id: \.name) { preset in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(preset.color)
                                .frame(width: 20, height: 20)
                            Text(preset.label)
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
            .sheet(isPresented: $showCustomColorGrid) {
                CustomColorGridView(selectedColor: $customColor)
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
}

struct CustomColorGridView: View {
    @Binding var selectedColor: Color
    @Environment(\.dismiss) private var dismiss

    @State private var previewColor: Color

    init(selectedColor: Binding<Color>) {
        _selectedColor = selectedColor
        _previewColor = State(initialValue: selectedColor.wrappedValue)
    }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 6)

    private var swatches: [Color] {
        var colors: [Color] = []
        for step in 0..<12 {
            let hue = Double(step) / 12
            for brightness in [0.9, 0.7, 0.5] {
                colors.append(Color(hue: hue, saturation: 0.75, brightness: brightness))
            }
        }
        for whiteLevel in stride(from: 0.95, through: 0.05, by: -0.15) {
            colors.append(Color(white: whiteLevel))
        }
        return colors
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(Array(swatches.enumerated()), id: \.offset) { _, swatch in
                            Button {
                                previewColor = swatch
                            } label: {
                                Circle()
                                    .fill(swatch)
                                    .frame(width: 36, height: 36)
                                    .overlay {
                                        Circle()
                                            .stroke(Color.primary, lineWidth: swatch.hexString == previewColor.hexString ? 3 : 0)
                                    }
                                    .overlay {
                                        if swatch.hexString == previewColor.hexString {
                                            Image(systemName: "checkmark")
                                                .font(.caption.bold())
                                                .foregroundStyle(.white)
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Custom Color")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        selectedColor = previewColor
                        dismiss()
                    }
                }
            }
        }
    }
}
