import SwiftUI
import UniformTypeIdentifiers

struct ResourceFormView: View {
    let viewModel: ResourceViewModel
    let resource: Resource?

    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var type: ResourceType = .pdf
    @State private var url: String = ""
    @State private var notes: String = ""
    @State private var isImportingFile = false
    @State private var importError: StudyHubError?

    private var isEditing: Bool {
        resource != nil
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (type != .pdf || !url.isEmpty)
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

                    if type == .pdf {
                        Button {
                            isImportingFile = true
                        } label: {
                            Label(url.isEmpty ? "Import PDF" : "Replace PDF", systemImage: "square.and.arrow.down")
                        }
                        if !url.isEmpty {
                            Label("File imported", systemImage: "checkmark.circle")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        TextField("URL", text: $url)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                            .autocorrectionDisabled()
                    }
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
            .fileImporter(isPresented: $isImportingFile, allowedContentTypes: [.pdf]) { result in
                switch result {
                case .success(let pickedURL):
                    do {
                        let imported = try AttachmentFileImporter.importFile(from: pickedURL)
                        url = imported.path
                    } catch let error as StudyHubError {
                        importError = error
                    } catch {
                        importError = AttachmentImportError.copyFailed
                    }
                case .failure:
                    importError = AttachmentImportError.copyFailed
                }
            }
            .alert(
                importError?.title ?? "Import Failed",
                isPresented: Binding(
                    get: { importError != nil },
                    set: { isPresented in
                        if !isPresented { importError = nil }
                    }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(importError?.message ?? "This file could not be imported.")
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
