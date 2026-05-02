import Foundation

enum DayCounter {
    static func ddayText(
        for targetDate: Date,
        repeatRule: RepeatRule,
        from referenceDate: Date = .now,
        calendar: Calendar = .current
    ) -> String {
        let displayDate = displayDate(
            for: targetDate,
            repeatRule: repeatRule,
            from: referenceDate,
            calendar: calendar
        )
        return ddayText(for: displayDate, from: referenceDate, calendar: calendar)
    }

    static func ddayText(
        for targetDate: Date,
        from referenceDate: Date = .now,
        calendar: Calendar = .current
    ) -> String {
        let days = daysRemaining(until: targetDate, from: referenceDate, calendar: calendar)

        if days == 0 {
            return "D-Day"
        }

        if days > 0 {
            return "D-\(days)"
        }

        return "D+\(abs(days))"
    }

    static func daysRemaining(
        until targetDate: Date,
        from referenceDate: Date = .now,
        calendar: Calendar = .current
    ) -> Int {
        let start = calendar.startOfDay(for: referenceDate)
        let target = calendar.startOfDay(for: targetDate)
        return calendar.dateComponents([.day], from: start, to: target).day ?? 0
    }

    static func daysIncludingStart(
        from startDate: Date,
        to referenceDate: Date = .now,
        calendar: Calendar = .current
    ) -> Int {
        let start = calendar.startOfDay(for: startDate)
        let reference = calendar.startOfDay(for: referenceDate)
        let days = calendar.dateComponents([.day], from: start, to: reference).day ?? 0
        return max(days + 1, 1)
    }

    static func displayDate(
        for targetDate: Date,
        repeatRule: RepeatRule,
        from referenceDate: Date = .now,
        calendar: Calendar = .current
    ) -> Date {
        switch repeatRule {
        case .none:
            return targetDate
        case .yearly:
            return nextYearlyOccurrence(
                of: targetDate,
                from: referenceDate,
                calendar: calendar
            )
        }
    }

    static func daysRemaining(
        until targetDate: Date,
        repeatRule: RepeatRule,
        from referenceDate: Date = .now,
        calendar: Calendar = .current
    ) -> Int {
        let displayDate = displayDate(
            for: targetDate,
            repeatRule: repeatRule,
            from: referenceDate,
            calendar: calendar
        )
        return daysRemaining(until: displayDate, from: referenceDate, calendar: calendar)
    }

    static func eventSortValue(
        targetDate: Date,
        repeatRule: RepeatRule,
        from referenceDate: Date = .now,
        calendar: Calendar = .current
    ) -> Int {
        let days = daysRemaining(
            until: targetDate,
            repeatRule: repeatRule,
            from: referenceDate,
            calendar: calendar
        )

        if days >= 0 {
            return days
        }

        return 1_000_000 + abs(days)
    }

    static func nextYearlyOccurrence(
        of targetDate: Date,
        from referenceDate: Date = .now,
        calendar: Calendar = .current
    ) -> Date {
        let targetComponents = calendar.dateComponents([.month, .day], from: targetDate)
        let referenceYear = calendar.component(.year, from: referenceDate)

        let candidate = yearlyDate(
            year: referenceYear,
            month: targetComponents.month ?? 1,
            day: targetComponents.day ?? 1,
            calendar: calendar
        )

        if calendar.startOfDay(for: candidate) >= calendar.startOfDay(for: referenceDate) {
            return candidate
        }

        return yearlyDate(
            year: referenceYear + 1,
            month: targetComponents.month ?? 1,
            day: targetComponents.day ?? 1,
            calendar: calendar
        )
    }

    private static func yearlyDate(
        year: Int,
        month: Int,
        day: Int,
        calendar: Calendar
    ) -> Date {
        let firstOfMonth = calendar.date(from: DateComponents(year: year, month: month, day: 1)) ?? Date()
        let dayRange = calendar.range(of: .day, in: .month, for: firstOfMonth)
        let maxDay = dayRange?.count ?? day
        let clampedDay = min(day, maxDay)

        return calendar.date(from: DateComponents(year: year, month: month, day: clampedDay)) ?? firstOfMonth
    }
}
