import Foundation

extension Notification.Name {
    /// Posted whenever a Reading's due date could have changed (created,
    /// edited, or deleted) — `HomeViewModel`/`CourseDetailViewModel` each
    /// compute their own "upcoming" snapshot once per `onAppear` rather
    /// than observing the object graph live, so without this, adding a
    /// reading due today from anywhere other than that exact screen's own
    /// next appearance would leave those snapshots stale.
    static let readingsDidChange = Notification.Name("readingsDidChange")
}
