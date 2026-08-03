import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

/// Shared "Add Attachment" sheet reused everywhere an `Attachment` gets
/// created — Notes, Lectures, and Assignments. (Readings keeps its own
/// simplified one-PDF-plus-one-link form by design; Resources mirrors this
/// same Type/File pattern in its own form since a `Resource` isn't an
/// `Attachment`.)
struct AttachmentFormView: View {
    /// Called with (filename, type rawValue, value) when the user taps Add.
    /// For a file-based kind (PDF/Image), `value` is a *temporary* staged
    /// file path, not yet permanent — the caller decides when (or whether)
    /// to finalize it. Link's `value` is already the final reference string.
    let onAdd: (String, String, String) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var filename: String = ""
    @State private var kind: AttachmentKind = .pdf
    @State private var url: String = ""
    @State private var temporaryPath: String?
    @State private var isImportingFile = false
    @State private var isPickingPhoto = false
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var importError: StudyHubError?
    @State private var didCommit = false

    private var canSave: Bool {
        !filename.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (!kind.isFileBased || temporaryPath != nil)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Filename") {
                    TextField("Filename", text: $filename)
                }

                Section("Type") {
                    Picker(selection: $kind) {
                        ForEach(AttachmentKind.allCases, id: \.self) { attachmentKind in
                            Text(attachmentKind.label).tag(attachmentKind)
                        }
                    } label: {
                        Label {
                            Text("Type")
                        } icon: {
                            Image(systemName: kind.icon)
                                .foregroundStyle(kind.color)
                        }
                    }
                }

                if kind.isFileBased {
                    Section("File") {
                        importButton
                        if temporaryPath != nil {
                            Label("File imported", systemImage: "checkmark.circle")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } else {
                    Section("Reference") {
                        TextField("URL or file reference", text: $url)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                }
            }
            .navigationTitle("Add Attachment")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        didCommit = true
                        onAdd(filename, kind.rawValue, kind.isFileBased ? (temporaryPath ?? "") : url)
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
            .fileImporter(
                isPresented: $isImportingFile,
                allowedContentTypes: kind == .pdf ? [.pdf] : [.image]
            ) { result in
                switch result {
                case .success(let pickedURL):
                    do {
                        let imported = try AttachmentFileImporter.importToTemporaryStorage(from: pickedURL)
                        replaceStagedFile(with: imported.path, filename: imported.filename)
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
            .onDisappear {
                if !didCommit, let temporaryPath {
                    AttachmentFileImporter.deleteTemporaryFile(at: temporaryPath)
                }
            }
        }
    }

    /// PDF only ever imports from Files; Image offers both a Photos-library
    /// pick and a Files import, since a photo you want to attach usually
    /// lives in the camera roll, not already saved as a standalone file.
    @ViewBuilder
    private var importButton: some View {
        if kind == .pdf {
            Button {
                isImportingFile = true
            } label: {
                Label(temporaryPath == nil ? "Import PDF" : "Replace PDF", systemImage: "square.and.arrow.down")
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
                Label(temporaryPath == nil ? "Add Image" : "Replace Image", systemImage: "square.and.arrow.down")
            }
        }
    }

    private func replaceStagedFile(with path: String, filename newFilename: String) {
        if let temporaryPath {
            AttachmentFileImporter.deleteTemporaryFile(at: temporaryPath)
        }
        temporaryPath = path
        filename = (newFilename as NSString).deletingPathExtension
    }

    /// `PhotosPickerItem` hands back raw `Data`, not a file already on disk
    /// (unlike `.fileImporter`), so there's no real filename to read —
    /// timestamped the same way the system Photos app names an export.
    private func importPickedPhoto(_ item: PhotosPickerItem) async {
        do {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                importError = AttachmentImportError.copyFailed
                return
            }
            let generatedFilename = "Photo-\(Int(Date.now.timeIntervalSince1970)).jpg"
            let imported = try AttachmentFileImporter.importDataToTemporaryStorage(data, filename: generatedFilename)
            replaceStagedFile(with: imported.path, filename: imported.filename)
        } catch let error as StudyHubError {
            importError = error
        } catch {
            importError = AttachmentImportError.copyFailed
        }
    }
}
