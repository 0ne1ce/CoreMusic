@preconcurrency import Foundation
@preconcurrency import UserNotifications

@MainActor
final class NotificationServiceImpl: NotificationService {

    // MARK: - Methods

    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        }
        catch {
            return false
        }
    }

    func rescheduleOnThisDayNotifications(memories: [Memory]) {
        let center = UNUserNotificationCenter.current()
        let memoryDates = memories.map { MemoryDate(date: $0.date) }

        center.getPendingNotificationRequests { pending in
            let existingIDs = pending
                .map(\.identifier)
                .filter { $0.hasPrefix(Constants.identifierPrefix) }

            center.removePendingNotificationRequests(withIdentifiers: existingIDs)

            Task { @MainActor [weak self] in
                self?.scheduleUpcoming(memoryDates: memoryDates, center: center)
            }
        }
    }

    // MARK: - Private methods

    private func scheduleUpcoming(
        memoryDates: [MemoryDate],
        center: UNUserNotificationCenter
    ) {
        let calendar = Calendar.current
        let now = Date()
        let currentYear = calendar.component(.year, from: now)

        let pastDates = memoryDates.filter { entry in
            calendar.component(.year, from: entry.date) != currentYear
        }

        var seen = Set<String>()
        var datePairs: [(month: Int, day: Int)] = []

        for entry in pastDates {
            let comp = calendar.dateComponents([.month, .day], from: entry.date)
            guard let month = comp.month, let day = comp.day else { continue }
            let key = "\(month)-\(day)"
            guard !seen.contains(key) else { continue }
            seen.insert(key)
            datePairs.append((month, day))
        }

        let upcomingDates = datePairs.compactMap { pair -> (month: Int, day: Int, next: Date)? in
            guard let next = Self.nextOccurrence(
                month: pair.month,
                day: pair.day,
                after: now,
                calendar: calendar
            )
            else { return nil }
            return (pair.month, pair.day, next)
        }
        .sorted { $0.next < $1.next }
        .prefix(Constants.maxScheduled)

        for entry in upcomingDates {
            var dateComponents = DateComponents()
            dateComponents.month = entry.month
            dateComponents.day = entry.day
            dateComponents.hour = Constants.notificationHour
            dateComponents.minute = 0

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: false
            )

            let content = UNMutableNotificationContent()
            content.title = "В этот день"
            content.body = "У вас есть воспоминания, связанные с этой датой!"
            content.sound = .default

            let identifier = "\(Constants.identifierPrefix)\(entry.month)-\(entry.day)"
            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )

            center.add(request)
        }
    }

    private static func nextOccurrence(
        month: Int,
        day: Int,
        after date: Date,
        calendar: Calendar
    ) -> Date? {
        var components = DateComponents()
        components.month = month
        components.day = day
        components.hour = Constants.notificationHour
        components.minute = 0

        return calendar.nextDate(
            after: date,
            matching: components,
            matchingPolicy: .nextTime
        )
    }
}

// MARK: - Private types

private struct MemoryDate: Sendable {
    let date: Date
}

private enum Constants {
    static let identifierPrefix = "onThisDay-"
    static let notificationHour = 12
    static let maxScheduled = 60
}
