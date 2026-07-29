import SwiftUI

struct ReadingFormView: View {
    let viewModel: ReadingViewModel
    let reading: Reading?

    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var author: String = ""
    @State private var pageCount: Int = 0
    @State private var currentPage: Int = 0
    @State private var estimatedMinutes: Int = 0
    @State private var hasDueDate: Bool = false
    @State private var dueDate: Date = .now
    @State private var notes: String = ""

    private var isEditing: Bool {
        reading != nil
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Reading") {
                    TextField("Title", text: $title)
                    TextField("Author", text: $author)

                    HStack {
                        Text("Total Pages")
                        Spacer()
                        SelectAllNumberField(value: $pageCount)
                            .onChange(of: pageCount) { _, newValue in
                                if newValue < 0 { pageCount = 0 }
                                if currentPage > pageCount { currentPage = pageCount }
                            }
                    }

                    HStack {
                        Text("Current Page")
                        Spacer()
                        SelectAllNumberField(value: $currentPage)
                            .onChange(of: currentPage) { _, newValue in
                                if newValue < 0 {
                                    currentPage = 0
                                } else if newValue > pageCount {
                                    currentPage = pageCount
                                }
                            }
                    }

                    HStack {
                        Text("Estimated Minutes")
                        Spacer()
                        SelectAllNumberField(value: $estimatedMinutes)
                            .onChange(of: estimatedMinutes) { _, newValue in
                                if newValue < 0 { estimatedMinutes = 0 }
                            }
                    }
                }

                Section("Due Date") {
                    Toggle("Set Due Date", isOn: $hasDueDate)
                    if hasDueDate {
                        StudyHubDateField(label: "Due Date", date: $dueDate)
                    }
                }

                Section("Notes") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(isEditing ? "Edit Reading" : "New Reading")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let reading {
                            viewModel.updateReading(
                                reading,
                                title: title,
                                author: author,
                                pageCount: pageCount,
                                currentPage: currentPage,
                                estimatedMinutes: estimatedMinutes,
                                dueDate: hasDueDate ? dueDate : nil,
                                notes: notes
                            )
                        } else {
                            viewModel.createReading(
                                title: title,
                                author: author,
                                pageCount: pageCount,
                                currentPage: currentPage,
                                estimatedMinutes: estimatedMinutes,
                                dueDate: hasDueDate ? dueDate : nil,
                                notes: notes
                            )
                        }
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                if let reading {
                    title = reading.title
                    author = reading.author
                    pageCount = reading.pageCount
                    currentPage = reading.currentPage
                    estimatedMinutes = reading.estimatedMinutes
                    notes = reading.notes
                    if let existingDueDate = reading.dueDate {
                        hasDueDate = true
                        dueDate = existingDueDate
                    }
                }
            }
        }
    }
}

/// A numeric text field that selects its entire existing value the moment it gains
/// focus — matching standard iOS behavior for tap-to-replace numeric entry. SwiftUI's
/// native `TextField` has no public API for this, so this wraps `UITextField` directly.
private struct SelectAllNumberField: UIViewRepresentable {
    @Binding var value: Int

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.keyboardType = .numberPad
        textField.textAlignment = .right
        textField.text = String(value)
        textField.delegate = context.coordinator
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textChanged), for: .editingChanged)
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        context.coordinator.value = $value
        let text = String(value)
        if !uiView.isFirstResponder && uiView.text != text {
            uiView.text = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(value: $value)
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        var value: Binding<Int>

        init(value: Binding<Int>) {
            self.value = value
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            DispatchQueue.main.async {
                textField.selectAll(nil)
            }
        }

        @objc func textChanged(_ textField: UITextField) {
            value.wrappedValue = Int(textField.text ?? "") ?? 0
        }
    }
}
