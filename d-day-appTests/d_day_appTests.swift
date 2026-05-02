import XCTest
@testable import d_day_app

final class d_day_appTests: XCTestCase {
    func testDdayTextForToday() throws {
        let calendar = Calendar(identifier: .gregorian)
        let today = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 5, day: 2)))

        XCTAssertEqual(
            DayCounter.ddayText(for: today, from: today, calendar: calendar),
            "D-Day"
        )
    }

    func testDdayTextForFutureDate() throws {
        let calendar = Calendar(identifier: .gregorian)
        let today = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 5, day: 2)))
        let target = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 5, day: 12)))

        XCTAssertEqual(
            DayCounter.ddayText(for: target, from: today, calendar: calendar),
            "D-10"
        )
    }

    func testDdayTextForPastDate() throws {
        let calendar = Calendar(identifier: .gregorian)
        let today = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 5, day: 2)))
        let target = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 4, day: 22)))

        XCTAssertEqual(
            DayCounter.ddayText(for: target, from: today, calendar: calendar),
            "D+10"
        )
    }

    func testDaysIncludingStartCountsFirstDayAsOne() throws {
        let calendar = Calendar(identifier: .gregorian)
        let start = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 5, day: 1)))
        let today = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 5, day: 2)))

        XCTAssertEqual(
            DayCounter.daysIncludingStart(from: start, to: today, calendar: calendar),
            2
        )
    }

    func testYearlyRepeatUsesThisYearWhenStillUpcoming() throws {
        let calendar = Calendar(identifier: .gregorian)
        let birthday = try XCTUnwrap(calendar.date(from: DateComponents(year: 2020, month: 5, day: 12)))
        let today = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 5, day: 2)))
        let expected = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 5, day: 12)))

        XCTAssertEqual(
            DayCounter.displayDate(for: birthday, repeatRule: .yearly, from: today, calendar: calendar),
            expected
        )
        XCTAssertEqual(
            DayCounter.ddayText(for: birthday, repeatRule: .yearly, from: today, calendar: calendar),
            "D-10"
        )
    }

    func testYearlyRepeatMovesToNextYearWhenDatePassed() throws {
        let calendar = Calendar(identifier: .gregorian)
        let anniversary = try XCTUnwrap(calendar.date(from: DateComponents(year: 2020, month: 4, day: 22)))
        let today = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 5, day: 2)))
        let expected = try XCTUnwrap(calendar.date(from: DateComponents(year: 2027, month: 4, day: 22)))

        XCTAssertEqual(
            DayCounter.displayDate(for: anniversary, repeatRule: .yearly, from: today, calendar: calendar),
            expected
        )
    }

    func testLeapDayYearlyRepeatFallsBackToFebruaryTwentyEight() throws {
        let calendar = Calendar(identifier: .gregorian)
        let leapDay = try XCTUnwrap(calendar.date(from: DateComponents(year: 2024, month: 2, day: 29)))
        let today = try XCTUnwrap(calendar.date(from: DateComponents(year: 2027, month: 1, day: 1)))
        let expected = try XCTUnwrap(calendar.date(from: DateComponents(year: 2027, month: 2, day: 28)))

        XCTAssertEqual(
            DayCounter.displayDate(for: leapDay, repeatRule: .yearly, from: today, calendar: calendar),
            expected
        )
    }

    func testPastOneTimeEventsSortAfterUpcomingEvents() throws {
        let calendar = Calendar(identifier: .gregorian)
        let today = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 5, day: 2)))
        let past = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 4, day: 22)))
        let future = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 5, day: 12)))

        XCTAssertGreaterThan(
            DayCounter.eventSortValue(targetDate: past, repeatRule: .none, from: today, calendar: calendar),
            DayCounter.eventSortValue(targetDate: future, repeatRule: .none, from: today, calendar: calendar)
        )
    }
}
