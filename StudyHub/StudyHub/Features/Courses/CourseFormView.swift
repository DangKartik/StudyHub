import SwiftUI

struct CourseFormView: View {
    let viewModel: CoursesViewModel
    let course: Course?

    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var courseCode: String = ""
    @State private var instructor: String = ""
    @State private var credits: Int = 0
    @State private var selectedColor: String = CourseFormView.colorPresets.first!.name

    static let colorPresets: [(name: String, color: Color)] = [
        ("blue", .blue),
        ("green", .green),
        ("orange", .orange),
        ("purple", .purple),
        ("pink", .pink),
        ("gray", .gray)
    ]

    static func colorValue(for name: String) -> Color {
        colorPresets.first { $0.name == name }?.color ?? .gray
    }

    private var isEditing: Bool {
        course != nil
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !courseCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Course") {
                    TextField("Name", text: $name)
                    TextField("Course Code", text: $courseCode)
                    TextField("Instructor", text: $instructor)
                    Stepper("Credits: \(credits)", value: $credits, in: 0...12)
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
                            viewModel.updateCourse(
                                course,
                                name: name,
                                courseCode: courseCode,
                                instructor: instructor,
                                credits: credits,
                                color: selectedColor
                            )
                        } else {
                            viewModel.createCourse(
                                name: name,
                                courseCode: courseCode,
                                instructor: instructor,
                                credits: credits,
                                color: selectedColor
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
                    credits = course.credits
                    selectedColor = course.courseColor
                }
            }
        }
    }
}
