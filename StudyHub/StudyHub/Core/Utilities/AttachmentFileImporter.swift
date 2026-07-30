import Foundation

/// Smallest-possible helper for copying a user-picked file (from `.fileImporter`)
/// into app-owned storage. Intentionally not a protocol-based, injected Service —
/// just a plain namespace called directly, the same way `Color.courseColor(from:)`
/// or `URL.mailto(_:)` are. See DECISION-029: a dedicated FileService is deferred
/// until multiple features actually need shared file-management logic.
enum AttachmentFileImporter {
    /// Copies a picked file into temporary staging rather than permanent
    /// storage — used while composing a new Note or Resource, before the user
    /// has committed to saving it (see Phase 3N.4 Part 3, Phase 3N.5.1). Call
    /// `finalize` when the owning object is actually saved, or
    /// `deleteTemporaryFile` if it's discarded.
    static func importToTemporaryStorage(from sourceURL: URL) throws -> (path: String, filename: String) {
        try copyFile(from: sourceURL, into: temporaryStagingDirectory())
    }

    /// Moves a temporarily-staged file into permanent attachment storage,
    /// returning its new, permanent path.
    static func finalize(temporaryPath: String) throws -> String {
        let sourceURL = URL(fileURLWithPath: temporaryPath)
        let destinationURL = try attachmentsDirectory()
            .appendingPathComponent(sourceURL.lastPathComponent)

        do {
            try FileManager.default.moveItem(at: sourceURL, to: destinationURL)
        } catch {
            throw AttachmentImportError.copyFailed
        }

        return destinationURL.path
    }

    /// Deletes a temporarily-staged file that was never finalized — called when
    /// the user cancels before saving, or replaces a staged file with another.
    /// Best-effort: a missing file is not an error worth surfacing.
    static func deleteTemporaryFile(at path: String) {
        try? FileManager.default.removeItem(atPath: path)
    }

    private static func copyFile(from sourceURL: URL, into directory: @autoclosure () throws -> URL) throws -> (path: String, filename: String) {
        let didStartAccessing = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if didStartAccessing {
                sourceURL.stopAccessingSecurityScopedResource()
            }
        }

        guard didStartAccessing else {
            throw AttachmentImportError.accessDenied
        }

        let filename = sourceURL.lastPathComponent
        let destinationURL = try directory().appendingPathComponent("\(UUID().uuidString)-\(filename)")

        do {
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
        } catch {
            throw AttachmentImportError.copyFailed
        }

        return (destinationURL.path, filename)
    }

    private static func attachmentsDirectory() throws -> URL {
        let appSupport = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let directory = appSupport.appendingPathComponent("Attachments", isDirectory: true)
        if !FileManager.default.fileExists(atPath: directory.path) {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory
    }

    private static func temporaryStagingDirectory() throws -> URL {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("PendingAttachments", isDirectory: true)
        if !FileManager.default.fileExists(atPath: directory.path) {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory
    }
}
