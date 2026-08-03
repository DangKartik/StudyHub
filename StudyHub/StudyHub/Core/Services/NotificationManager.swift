import Foundation
import UserNotifications

/// Local-only notification scheduling (no server, no push infra) —
/// `UNUserNotificationCenter` wrapper following the same
/// protocol-plus-concrete-class shape as `PDFServiceProtocol`/`PDFService`.
/// Every scheduling call uses a deterministic, caller-supplied identifier
/// (usually derived from a model's `UUID`) so rescheduling is just "cancel
/// then add again" — no separate lookup table needed.
protocol NotificationSchedulingProtocol {
    func requestAuthorization() async -> Bool
    func authorizationStatus() async -> UNAuthorizationStatus
    func scheduleNotification(id: String, title: String, body: String, date: Date)
    func scheduleDailyNotification(id: String, title: String, body: String, hour: Int, minute: Int)
    func cancelNotification(id: String)
    func cancelNotifications(ids: [String])
}

@MainActor
final class NotificationManager: NotificationSchedulingProtocol {
    private let center = UNUserNotificationCenter.current()

    func requestAuthorization() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }

    /// A no-op when `date` has already passed — `UNCalendarNotificationTrigger`
    /// would otherwise fire immediately, which is never what a "due soon"
    /// reminder scheduled against a past-due item should do.
    func scheduleNotification(id: String, title: String, body: String, date: Date) {
        guard date > .now else { return }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(request)
    }

    /// Fires every day at `hour:minute` — used for the flashcard/active
    /// recall digest. Re-adding a request with the same `id` atomically
    /// replaces the previous one, which is how the digest's body text stays
    /// current with the live due-count each time it's rescheduled.
    func scheduleDailyNotification(id: String, title: String, body: String, hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(request)
    }

    func cancelNotification(id: String) {
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }

    func cancelNotifications(ids: [String]) {
        guard !ids.isEmpty else { return }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }
}
