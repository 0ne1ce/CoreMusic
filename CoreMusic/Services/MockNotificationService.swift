import Foundation

@MainActor
final class MockNotificationService: NotificationService {

    // MARK: - Methods

    func requestAuthorization() async -> Bool {
        true
    }

    func rescheduleOnThisDayNotifications(memories: [Memory]) { }
}
