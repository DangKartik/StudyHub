import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct ResourceFormView: View {
    let viewModel: ResourceViewModel
    let resource: Resource?

    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var type: AttachmentKind = .pdf
    @State private var url: String = ""
    @State private var notes: String = ""
    @State private var isImportingFile = false
    @State private var isPickingPhoto = false
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var importError: StudyHubError?
    @State private var stagedTemporaryPath: String?
    @State private var didSave = false

    private var isEditing: Bool {
        resource != nil
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (!type.isFileBased || !url.isEmpty)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)

                    Picker(selection: $type) {
                        ForEach(AttachmentKind.allCases, id: \.self) { type in
                            Text(type.label).tag(type)
                        }
                    } label: {
                        Label {
                            Text("Type")
                        } icon: {
                            Image(systemName: type.icon)
                                .foregroundStyle(type.color)
                        }
                    }

                    if type.isFileBased {
                        importButton
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
                } header: {
                    Label("Resource", systemImage: "folder.fill")
                }

                Section {
                    PlaceholderTextEditor(placeholder: "Any extra context for this resource…", text: $notes)
                        .frame(minHeight: 120)
                } header: {
                    Label("Notes", systemImage: "text.alignleft")
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
                        saveResource()
                    }
                    .disabled(!canSave)
                }
            }
            .fileImporter(
                isPresented: $isImportingFile,
                allowedContentTypes: type == .pdf ? [.pdf] : [.image]
            ) { result in
                switch result {
                case .success(let pickedURL):
                    do {
                        let imported = try AttachmentFileImporter.importToTemporaryStorage(from: pickedURL)
                        applyStagedFile(path: imported.path, filename: imported.filename)
                    } catch let error as StudyHubError {
                        importError = error
                    } catch {
                        importError = AttachmentImportError.copyFailed
                    }
                case .failure:
                    importError = AttachmentImportError.copyFailed
                }
            }
            .photosPicker(isPresented: $isPickingPhoto, selection: $photosPickerItem, matching: .images)
            .onChange(of: photosPickerItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    await importPickedPhoto(newItem)
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
            .onDisappear {
                if !didSave, let stagedTemporaryPath {
                    AttachmentFileImporter.deleteTemporaryFile(at: stagedTemporaryPath)
                }
            }
        }
    }

    /// PDF only ever imports from Files; Image offers both a Photos-library
    /// pick and a Files import, matching `AttachmentFormView`'s identical
    /// menu — same import experience whether you're adding a course
    /// Resource or an attachment to a Note/Lecture/Assignment.
    @ViewBuilder
    private var importButton: some View {
        if type == .pdf {
            Button {
                isImportingFile = true
            } label: {
                Label(url.isEmpty ? "Import PDF" : "Replace PDF", systemImage: "square.and.arrow.down")
            }
        } else {
            Menu {
                Button {
                    isPickingPhoto = true
                } label: {
                    Label("Choose Photo", systemImage: "photo.on.rectangle")
                }
                Button {
                    isImportingFile = true
                } label: {
                    Label("Import File", systemImage: "folder")
                }
            } label: {
                Label(url.isEmpty ? "Add Image" : "Replace Image", systemImage: "square.and.arrow.down")
            }
        }
    }

    private func applyStagedFile(path: String, filename: String) {
        if let stagedTemporaryPath {
            AttachmentFileImporter.deleteTemporaryFile(at: stagedTemporaryPath)
        }
        stagedTemporaryPath = path
        url = path
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            title = (filename as NSString).deletingPathExtension
        }
    }

    /// `PhotosPickerItem` hands back raw `Data`, not a file already on disk
    /// (unlike `.fileImporter`) — same handling as `AttachmentFormView`'s.
    private func importPickedPhoto(_ item: PhotosPickerItem) async {
        do {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                importError = AttachmentImportError.copyFailed
                return
            }
            let generatedFilename = "Photo-\(Int(Date.now.timeIntervalSince1970)).jpg"
            let imported = try AttachmentFileImporter.importDataToTemporaryStorage(data, filename: generatedFilename)
            applyStagedFile(path: imported.path, filename: imported.filename)
        } catch let error as StudyHubError {
            importError = error
        } catch {
            importError = AttachmentImportError.copyFailed
        }
    }

    /// A newly-imported file (`stagedTemporaryPath`) lives in temporary
    /// storage until Save is actually pressed — only then is it finalized
    /// into permanent attachment storage, matching the Notes staging
    /// pattern (see Phase 3N.4 Part 3). If no new file was imported this
    /// session (editing an existing file-based resource without replacing
    /// it, or a Link type), `url` already holds the correct, unchanged
    /// reference.
    private func saveResource() {
        var finalURL = url
        if let stagedTemporaryPath {
            do {
                finalURL = try AttachmentFileImporter.finalize(temporaryPath: stagedTemporaryPath)
            } catch let error as StudyHubError {
                importError = error
                return
            } catch {
                importError = AttachmentImportError.copyFailed
                return
            }
        }

        didSave = true
        if let resource {
            viewModel.updateResource(resource, title: title, type: type, url: finalURL, notes: notes)
        } else {
            viewModel.createResource(title: title, type: type, url: finalURL, notes: notes)
        }
        dismiss()
    }
}
