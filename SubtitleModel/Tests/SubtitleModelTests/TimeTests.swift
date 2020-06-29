@testable import SubtitleModel
import XCTest

final class TimeTests: XCTestCase {
    func testTimeWithSecondsRawValue() {
        // given
        let time = Time(hours: 2, minutes: 3, seconds: 5)

        // when
        let sut = time.rawValue

        // then
        XCTAssertEqual("02:03:05", sut)
    }

    func testTimeWithoutSecondsRawValue() {
        // given
        let time = Time(hours: 2, minutes: 3, seconds: 0)

        // when
        let sut = time.rawValue

        // then
        XCTAssertEqual("02:03", sut)
    }

    func testTimeWithSecondsDescription() {
        // given
        let time = Time(hours: 2, minutes: 3, seconds: 5)

        // when
        let sut = time.description

        // then
        XCTAssertEqual("02:03:05", sut)
    }

    func testTimeWithoutSecondsDescription() {
        // given
        let time = Time(hours: 2, minutes: 3, seconds: 0)

        // when
        let sut = time.description

        // then
        XCTAssertEqual("02:03", sut)
    }

    func testRawValueWithSecondsToTime() {
        // given
        let time = "02:03:05"

        // when
        let sut = Time(rawValue: time)

        // then
        XCTAssertEqual(Time(hours: 2, minutes: 3, seconds: 5), sut)
    }

    func testRawValueWithoutSecondsToTime() {
        // given
        let time = "02:03"

        // when
        let sut = Time(rawValue: time)

        // then
        XCTAssertEqual(Time(hours: 2, minutes: 3, seconds: 0), sut)
    }

    func testDescriptionWithSecondsToTime() {
        // given
        let time = "02:03:05"

        // when
        let sut = Time(time)

        // then
        XCTAssertEqual(Time(hours: 2, minutes: 3, seconds: 5), sut)
    }

    func testDescriptionWithoutSecondsToTime() {
        // given
        let time = "02:03"

        // when
        let sut = Time(time)

        // then
        XCTAssertEqual(Time(hours: 2, minutes: 3, seconds: 0), sut)
    }

    func testNegativeDescriptionWithoutSecondsToTime() {
        // given
        let time = "-02:03"

        // when
        let sut = Time(time)

        // then
        XCTAssertEqual(Time(hours: -2, minutes: 3, seconds: 0), sut)
    }

    func testNegativeDescriptionWithSecondsToTime() {
        // given
        let time = "-02:03:09"

        // when
        let sut = Time(time)

        // then
        XCTAssertEqual(Time(hours: -2, minutes: 3, seconds: 9), sut)
    }

    func testPositiveDescriptionWithoutSecondsToTime() {
        // given
        let time = "+02:03"

        // when
        let sut = Time(time)

        // then
        XCTAssertEqual(Time(hours: 2, minutes: 3, seconds: 0), sut)
    }

    func testPositiveDescriptionWithSecondsToTime() {
        // given
        let time = "+02:03:09"

        // when
        let sut = Time(time)

        // then
        XCTAssertEqual(Time(hours: 2, minutes: 3, seconds: 9), sut)
    }

    func testStringLiteralWithSecondsToTime() {
        // given
        let sut: Time = "02:03:05"

        // then
        XCTAssertEqual(Time(hours: 2, minutes: 3, seconds: 5), sut)
    }

    func testStringLiteralWithoutSecondsToTime() {
        // given
        let sut: Time = "02:03"

        // then
        XCTAssertEqual(Time(hours: 2, minutes: 3, seconds: 0), sut)
    }
}

extension TimeTests {
    private var seconds: Double { return 1 }
    private var minutes: Double { return 60 }
    private var hours: Double { return minutes * 60 }
    private var days: Double { return hours * 24 }
    private var secondsAndTimeEquivalents: [(expectedInterval: TimeInterval, time: Time)] {
        return [
            (0, "00:00:00"),
            (1, "00:00:01"),
            (31, "00:00:31"),
            (59, "00:00:59"),
            (60, "00:01:00"),
            (61, "00:01:01"),
            (91, "00:01:31"),
            (119, "00:01:59"),
            (120, "00:02:00"),
            (121, "00:02:01"),
            (59 * minutes + 0 * seconds, "00:59:00"),
            (59 * minutes + 59 * seconds, "00:59:59"),
            (61 * minutes + 02 * seconds, "01:01:02"),
            (7 * hours + 39 * minutes + 59 * seconds, "07:39:59"),
            (86369, "23:59:29")
        ]
    }

    func testTimeFromSeconds() {
        // given
        let expectedTimes: [(expectedInterval: TimeInterval, time: Time)] = secondsAndTimeEquivalents + [
            (5 * days + 7 * hours + 39 * minutes + 59 * seconds, "127:39:59" as Time)
        ]

        // when
        let allCases = expectedTimes.map { (testCase: (interval: TimeInterval, expected: Time)) -> (sut: Time, expected: Time) in
            let sut = Time(totalSeconds: testCase.interval)
            return (sut: sut, expected: testCase.expected)
        }

        // then
        XCTAssertEqual(expectedTimes.count, allCases.count)
        allCases.forEach { testCase in
            XCTAssertEqual(testCase.expected, testCase.sut)
        }
    }

    func testTotalSecondsFromTime() {
        // given
        let expectedTimes = secondsAndTimeEquivalents + [
            (5 * days + 7 * hours + 39 * minutes + 59 * seconds, "127:39:59" as Time)
        ]

        // when
        let allCases = expectedTimes.map { (testCase: (expectedInterval: TimeInterval, time: Time)) -> (expectedInterval: TimeInterval, sut: TimeInterval) in
            let sut = Double(testCase.time.totalSeconds)
            return (expectedInterval: testCase.expectedInterval, sut: sut)
        }

        // then
        XCTAssertEqual(expectedTimes.count, allCases.count)
        allCases.forEach { testCase in
            XCTAssertEqual(testCase.expectedInterval, testCase.sut)
        }
    }

    func testTotalMinutesFromTime() {
        // given
        let expectedTimes = secondsAndTimeEquivalents + [
            (5 * days + 7 * hours + 39 * minutes + 59 * seconds, "127:39:59" as Time)
        ]

        // when
        let allCases = expectedTimes.map { (testCase: (expectedInterval: TimeInterval, time: Time)) -> (expectedInterval: TimeInterval, sut: TimeInterval) in
            let sut = Double(testCase.time.totalMinutes)
            return (expectedInterval: testCase.expectedInterval / minutes, sut: sut)
        }

        // then
        XCTAssertEqual(expectedTimes.count, allCases.count)
        allCases.forEach { testCase in
            XCTAssertEqual(testCase.expectedInterval, testCase.sut, accuracy: Double.ulpOfOne)
        }
    }

    func testTotalHoursFromTime() {
        // given
        let expectedTimes = secondsAndTimeEquivalents + [
            (5 * days + 7 * hours + 39 * minutes + 59 * seconds, "127:39:59" as Time)
        ]

        // when
        let allCases = expectedTimes.map { (testCase: (expectedInterval: TimeInterval, time: Time)) -> (expectedInterval: TimeInterval, sut: TimeInterval) in
            let sut = Double(testCase.time.totalHours)
            return (expectedInterval: testCase.expectedInterval / hours, sut: sut)
        }

        // then
        XCTAssertEqual(expectedTimes.count, allCases.count)
        allCases.forEach { testCase in
            XCTAssertEqual(testCase.expectedInterval, testCase.sut, accuracy: Double.ulpOfOne)
        }
    }

    func testTotalMillisecondsInit() {
        // given
        let totalMilli: TimeInterval = 404142

        // when
        let sut = Time(totalMilliseconds: totalMilli)

        // then
        XCTAssertEqual(sut.totalMilliseconds, 404142, accuracy: 0.000000001)
        XCTAssertEqual(sut.totalSeconds, 404.142, accuracy: 0.000000001)
        XCTAssertEqual(sut.totalMinutes, 6.7357, accuracy: 0.000000001)
        XCTAssertEqual(sut.totalHours, 0.112261667, accuracy: 0.000000001)
    }

    func testTotalSecondsInit() {
        // given
        let totalSeconds: TimeInterval = 404.142

        // when
        let sut = Time(totalSeconds: totalSeconds)

        // then
        XCTAssertEqual(sut.totalMilliseconds, 404142, accuracy: 0.000000001)
        XCTAssertEqual(sut.totalSeconds, 404.142, accuracy: 0.000000001)
        XCTAssertEqual(sut.totalMinutes, 6.7357, accuracy: 0.000000001)
        XCTAssertEqual(sut.totalHours, 0.112261667, accuracy: 0.000000001)
    }

    func testEncode() throws {
        // given
        let dict = ["sut": Time(rawValue: "02:03:05")]

        // when
        let data = try JSONEncoder().encode(dict)
        let json = String(data: data, encoding: .utf8)

        // then
        XCTAssertEqual(json, "{\"sut\":\"02:03:05\"}")
    }

    func testDecode() throws {
        // given
        let json = "{\"sut\":\"02:03:05\"}"

        // when
        let data = json.data(using: .utf8)!
        let dict = try JSONDecoder().decode([String: Time].self, from: data)

        // then
        XCTAssertEqual(Time(rawValue: "02:03:05"), dict["sut"])
    }

    func testZero() {
        // given
        let expected = "00:00"

        // when
        let sut = Time.zero

        // then
        XCTAssertEqual(sut.description, expected)
    }

    func testSort() {
        // given
        let unsorted = [Time(stringLiteral: "12:59:20"), "11:25:51", "29:01", "01:30:44", "21:02:42"]
        let expectedSorted = [Time(stringLiteral: "01:30:44"), "11:25:51", "12:59:20", "21:02:42", "29:01"]

        // when
        let calculatedSorted = unsorted.sorted()

        // then
        XCTAssertEqual(calculatedSorted, expectedSorted)
        XCTAssertNotEqual(unsorted, calculatedSorted)
    }

    static var allTests = [
        ("testTimeWithSecondsRawValue", testTimeWithSecondsRawValue),
        ("testTimeWithoutSecondsRawValue", testTimeWithoutSecondsRawValue),
        ("testTimeWithSecondsDescription", testTimeWithSecondsDescription),
        ("testTimeWithoutSecondsDescription", testTimeWithoutSecondsDescription),
        ("testRawValueWithSecondsToTime", testRawValueWithSecondsToTime),
        ("testRawValueWithoutSecondsToTime", testRawValueWithoutSecondsToTime),
        ("testDescriptionWithSecondsToTime", testDescriptionWithSecondsToTime),
        ("testDescriptionWithoutSecondsToTime", testDescriptionWithoutSecondsToTime),
        ("testNegativeDescriptionWithoutSecondsToTime", testNegativeDescriptionWithoutSecondsToTime),
        ("testNegativeDescriptionWithSecondsToTime", testNegativeDescriptionWithSecondsToTime),
        ("testPositiveDescriptionWithoutSecondsToTime", testPositiveDescriptionWithoutSecondsToTime),
        ("testPositiveDescriptionWithSecondsToTime", testPositiveDescriptionWithSecondsToTime),
        ("testStringLiteralWithSecondsToTime", testStringLiteralWithSecondsToTime),
        ("testStringLiteralWithoutSecondsToTime", testStringLiteralWithoutSecondsToTime),
        ("testTimeFromSeconds", testTimeFromSeconds),
        ("testTotalSecondsFromTime", testTotalSecondsFromTime),
        ("testTotalMinutesFromTime", testTotalMinutesFromTime),
        ("testTotalHoursFromTime", testTotalHoursFromTime),
        ("testTotalMillisecondsInit", testTotalMillisecondsInit),
        ("testTotalSecondsInit", testTotalSecondsInit),
        ("testEncode", testEncode),
        ("testDecode", testDecode),
        ("testZero", testZero),
        ("testSort", testSort)
    ]
}
