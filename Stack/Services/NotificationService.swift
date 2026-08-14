import Foundation
import UserNotifications

/// Schedules the repeating local notifications that back the Settings toggles.
enum NotificationService {

    private static let protocolReminderID = "stack.protocolReminder"
    private static let eveningCheckInID   = "stack.eveningCheckIn"

    static func updateProtocolReminder(enabled: Bool, secondsFromMidnight: Double) {
        update(
            id: protocolReminderID,
            enabled: enabled,
            secondsFromMidnight: secondsFromMidnight,
            title: "Daily Protocol",
            body: "Check in on today's blocks and keep the streak alive."
        )
    }

    static func updateEveningCheckIn(enabled: Bool, secondsFromMidnight: Double) {
        update(
            id: eveningCheckInID,
            enabled: enabled,
            secondsFromMidnight: secondsFromMidnight,
            title: "Evening Check-In",
            body: "Wrap up the day — log your workout, supplements, and protocol."
        )
    }

    /// Re-applies both schedules from stored preferences (e.g. after permission
    /// is granted later than the toggle was flipped).
    static func syncFromPreferences() {
        let defaults = UserDefaults.standard
        updateProtocolReminder(
            enabled: defaults.bool(forKey: "protocolReminderEnabled"),
            secondsFromMidnight: defaults.object(forKey: "protocolReminderSecs") as? Double ?? 8 * 3600
        )
        updateEveningCheckIn(
            enabled: defaults.bool(forKey: "eveningCheckInEnabled"),
            secondsFromMidnight: defaults.object(forKey: "eveningCheckInSecs") as? Double ?? 21 * 3600
        )
    }

    static func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let granted = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        return granted
    }

    // MARK: - Private

    private static func update(
        id: String,
        enabled: Bool,
        secondsFromMidnight: Double,
        title: String,
        body: String
    ) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [id])
        guard enabled else { return }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body  = body
        content.sound = .default

        var components = DateComponents()
        let totalMinutes = Int(secondsFromMidnight) / 60
        components.hour   = totalMinutes / 60
        components.minute = totalMinutes % 60

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }
}
