import Foundation
import SwiftData

@Model
final class CalendarEventReference {
    var id: UUID = UUID()
    var eventIdentifier: String = ""
    var calendarIdentifier: String = ""
    var lastSynced: Date?
    var syncStatus: SyncStatus = SyncStatus.pending

    init(
        id: UUID = UUID(),
        eventIdentifier: String,
        calendarIdentifier: String,
        lastSynced: Date? = nil,
        syncStatus: SyncStatus = .pending
    ) {
        self.id = id
        self.eventIdentifier = eventIdentifier
        self.calendarIdentifier = calendarIdentifier
        self.lastSynced = lastSynced
        self.syncStatus = syncStatus
    }
}
