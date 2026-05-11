import Foundation

@MainActor
protocol NotificationService: AnyObject {
    func requestAuthorization() async -> Bool
    func rescheduleOnThisDayNotifications(memories: [Memory])
}
