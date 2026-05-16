import Foundation

enum DaySurfaceSnapshotFactory {
    static func make(
        profiles: [CoupleProfile],
        events: [DayEvent],
        from referenceDate: Date = .now
    ) -> DaySurfaceSnapshot {
        let profile = profiles.first
        let orderedEvents = sortedEvents(events, from: referenceDate)
        let event = orderedEvents.first { $0.isPinned } ?? orderedEvents.first

        return DaySurfaceSnapshot(
            coupleTitle: coupleTitle(for: profile),
            daysText: daysText(for: profile, from: referenceDate),
            eventTitle: event?.title ?? "첫 D-Day",
            ddayText: event.map {
                DayCounter.ddayText(
                    for: $0.targetDate,
                    repeatRule: $0.repeatRule,
                    from: referenceDate
                )
            } ?? "D-Day",
            symbolName: event?.kind.symbolName ?? "calendar",
            colorHex: event?.colorHex ?? "2F6FED",
            updatedAt: referenceDate
        )
    }

    private static func sortedEvents(
        _ events: [DayEvent],
        from referenceDate: Date
    ) -> [DayEvent] {
        events.sorted { lhs, rhs in
            let lhsValue = DayCounter.eventSortValue(
                targetDate: lhs.targetDate,
                repeatRule: lhs.repeatRule,
                from: referenceDate
            )
            let rhsValue = DayCounter.eventSortValue(
                targetDate: rhs.targetDate,
                repeatRule: rhs.repeatRule,
                from: referenceDate
            )

            if lhsValue == rhsValue {
                return lhs.title.localizedCompare(rhs.title) == .orderedAscending
            }

            return lhsValue < rhsValue
        }
    }

    private static func coupleTitle(for profile: CoupleProfile?) -> String {
        guard let profile else {
            return "시작일"
        }

        let first = profile.firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let partner = profile.partnerName.trimmingCharacters(in: .whitespacesAndNewlines)

        if first.isEmpty && partner.isEmpty {
            return "시작일"
        }

        if first.isEmpty {
            return partner
        }

        if partner.isEmpty {
            return first
        }

        return "\(first) & \(partner)"
    }

    private static func daysText(for profile: CoupleProfile?, from referenceDate: Date) -> String {
        guard let profile else {
            return "1일째"
        }

        return "\(DayCounter.daysIncludingStart(from: profile.startedAt, to: referenceDate))일째"
    }
}
