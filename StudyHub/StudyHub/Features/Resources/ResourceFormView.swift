import SwiftUI

struct ResourceFormView: View {
    let viewModel: ResourceViewModel
    let resource: Resource?

    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var type: ResourceType = .website
    @State private var url: String = ""
    @State private var notes: String = ""

    private var isEditing: Bool {
        resource != nil
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Resource") {
                    TextField("Title", text: $title)

                    Picker("Type", selection: $type) {
                        ForEach(ResourceType.allCases, id: \.self) { type in
                            Text(type.label).tag(type)
                        }
                    }

                    TextField("URL", text: $url)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 120)
                }
            }
            .navigationTitle(isEditing ? "Edit Resource" : "New Resource")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let resource {
                            viewModel.updateResource(
                                resource,
                                title: title,
                                type: type,
                                url: url,
                                notes: notes
                            )
                        } else {
                            viewModel.createResource(
                                title: title,
                                type: type,
                                url: url,
                                notes: notes
                            )
                        }
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                if let resource {
                    title = resource.title
                    type = resource.type
                    url = resource.url
                    notes = resource.notes
                }
            }
        }
    }
}
