import Foundation
import SwiftData

@Model
final class Attachment {
    var id: UUID = UUID()
    var filename: String = ""
    var type: String = ""
    var url: String = ""
    var size: Int = 0
    var createdAt: Date = Date.now

    /// Serialized `PKDrawing.dataRepresentation()` for this attachment's PDF
    /// markup, in PDF page-native coordinate space (Phase 3N.6.4) — never
    /// raster/flattened, always re-hydrated via `PKDrawing(data:)`.
    /// `.externalStorage` keeps drawing blobs out of the inline row, same
    /// reasoning as every other binary-ish field in this app.
    @Attribute(.externalStorage) var markupData: Data?

    var lecture: Lecture?
    var assignment: Assignment?
    var reading: Reading?
    var note: Note?

    init(
        id: UUID = UUID(),
        filename: String,
        type: String,
        url: String,
        size: Int = 0,
        createdAt: Date = Date.now,
        markupData: Data? = nil
    ) {
        self.id = id
        self.filename = filename
        self.type = type
        self.url = url
        self.size = size
        self.createdAt = createdAt
        self.markupData = markupData
    }
}
