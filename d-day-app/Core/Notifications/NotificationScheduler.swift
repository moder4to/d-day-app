import Foundation
import UserNotifications

struct NotificationPreferences: Equatable {
    var isEnabled: Bool
    var notifyOnDay: Bool
    var notifyOneDayBefore: Bool
    var notifySevenDaysBefore: Bool
    var hour: Int
    var minute: Int

    var activeOffsets: [Int] {
        var offsets: [Int] = []

        if notifyOnDay {
            offsets.append(0)
        }

        if notifyOneDayBefore {
            offsets.append(1)
        }

        if notifySevenDaysBefore {
            offsets.append(7)
        }

        return offsets
    }
}

enum NotificationSettingsStore {
    static let enabledKey = "notifications.enabled"
    static let onDayKey = "notifications.onDay"
    static let oneDayBeforeKey = "notifications.oneDayBefore"
    static let sevenDaysBeforeKey = "notifications.sevenDaysBefore"
    static let hourKey = "notifications.hour"
    static let minuteKey = "notifications.minute"

    static var preferences: NotificationPreferences {
        let defaults = UserDefaults.standard

        if defaults.object(forKey: onDayKey) == nil {
            defaults.set(true, forKey: onDayKey)
        }

        if defaults.object(forKey: oneDayBeforeKey) == nil {
            defaults.set(true, forKey: oneDayBeforeKey)
        }

        if defaults.object(forKey: sevenDaysBeforeKey) == nil {
            defaults.set(false, forKey: sevenDaysBeforeKey)
        }

        if defaults.object(forKey: hourKey) == nil {
            defaults.set(9, forKey: hourKey)
        }

        if defaults.object(forKey: minuteKey) == nil {
            defaults.set(0, forKey: minuteKey)
        }

        return NotificationPreferences(
            isEnabled: defaults.bool(forKey: enabledKey),
            notifyOnDay: defaults.bool(forKey: onDayKey),
            notifyOneDayBefore: defaults.bool(forKey: oneDayBeforeKey),
            notifySevenDaysBefore: defaults.bool(forKey: sevenDaysBeforeKey),
            hour: max(0, min(23, defaults.integer(forKey: hourKey))),
            minute: max(0, min(59, defaults.integer(forKey: minuteKey)))
        )
    }
}

enum NotificationScheduler {
    private static let center = UNUserNotificationCenter.current()

    static func authorizationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }

    static func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    static func rescheduleAll(events: [DayEvent]) async {
        let preferences = NotificationSettingsStore.preferences
        cancel(events: events)

        guard preferences.isEnabled, !preferences.activeOffsets.isEmpty else {
            return
        }

        let status = await authorizationStatus()
        guard status == .authorized || status == .provisional || status == .ephemeral else {
            return
        }

        for event in events {
            schedule(event: event, preferences: preferences)
        }
    }

    static func cancel(event: DayEvent) {
        center.removePendingNotificationRequests(withIdentifiers: identifiers(for: event))
    }

    static func cancel(events: [DayEvent]) {
        center.removePendingNotificationRequests(
            withIdentifiers: events.flatMap { identifiers(for: $0) }
        )
    }

    static func identifiers(for event: DayEvent) -> [String] {
        [0, 1, 7].map { identifier(for: event, dayOffset: $0) }
    }

    private static func schedule(event: DayEvent, preferences: NotificationPreferences) {
        for offset in preferences.activeOffsets {
            guard let request = notificationRequest(
                for: event,
                dayOffset: offset,
                preferences: preferences
            ) else {
                continue
            }

            center.add(request)
        }
    }

    private static func notificationRequest(
        for event: DayEvent,
        dayOffset: Int,
        preferences: NotificationPreferences,
        referenceDate: Date = .now,
        calendar: Calendar = .current
    ) -> UNNotificationRequest? {
        let occurrence = DayCounter.displayDate(
            for: event.targetDate,
            repeatRule: event.repeatRule,
            from: referenceDate,
            calendar: calendar
        )

        guard let notificationDay = calendar.date(byAdding: .day, value: -dayOffset, to: occurrence) else {
            return nil
        }

        let fireDate = calendar.date(
            bySettingHour: preferences.hour,
            minute: preferences.minute,
            second: 0,
            of: notificationDay
        ) ?? notificationDay

        guard event.repeatRule == .yearly || fireDate >= referenceDate else {
            return nil
        }

        let content = UNMutableNotificationContent()
        content.title = title(for: event, dayOffset: dayOffset)
        content.body = body(for: event, dayOffset: dayOffset)
        content.sound = .default

        var components = calendar.dateComponents([.month, .day, .hour, .minute], from: fireDate)
        var repeats = event.repeatRule == .yearly

        if !repeats {
            components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        } else if fireDate < referenceDate {
            repeats = false
        }

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: repeats)

        return UNNotificationRequest(
            identifier: identifier(for: event, dayOffset: dayOffset),
            content: content,
            trigger: trigger
        )
    }

    private static func identifier(for event: DayEvent, dayOffset: Int) -> String {
        "day-event.\(event.stableID).offset.\(dayOffset)"
    }

    private static func title(for event: DayEvent, dayOffset: Int) -> String {
        switch dayOffset {
        case 0:
            return "\(event.title) D-Day"
        case 1:
            return "\(event.title) 하루 전"
        default:
            return "\(event.title) \(dayOffset)일 전"
        }
    }

    private static func body(for event: DayEvent, dayOffset: Int) -> String {
        switch dayOffset {
        case 0:
            return "오늘은 \(event.title)입니다."
        case 1:
            return "내일은 \(event.title)입니다."
        default:
            return "\(event.title)이 \(dayOffset)일 남았습니다."
        }
    }
}
