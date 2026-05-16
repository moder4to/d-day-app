import Foundation

struct DaySurfaceSnapshot: Codable, Hashable, Sendable {
    var coupleTitle: String
    var daysText: String
    var eventTitle: String
    var ddayText: String
    var symbolName: String
    var colorHex: String
    var updatedAt: Date

    static let placeholder = DaySurfaceSnapshot(
        coupleTitle: "시작일",
        daysText: "1일째",
        eventTitle: "첫 D-Day",
        ddayText: "D-Day",
        symbolName: "calendar",
        colorHex: "2F6FED",
        updatedAt: .now
    )

    var inlineText: String {
        "\(coupleTitle) \(daysText)"
    }
}

enum DaySurfaceSnapshotStore {
    private static var defaults: UserDefaults {
        UserDefaults(suiteName: DaySurfaceConstants.appGroupIdentifier) ?? .standard
    }

    static func load() -> DaySurfaceSnapshot {
        guard
            let data = defaults.data(forKey: DaySurfaceConstants.snapshotKey),
            let snapshot = try? JSONDecoder().decode(DaySurfaceSnapshot.self, from: data)
        else {
            return .placeholder
        }

        return snapshot
    }

    static func save(_ snapshot: DaySurfaceSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else {
            return
        }

        defaults.set(data, forKey: DaySurfaceConstants.snapshotKey)
    }
}
