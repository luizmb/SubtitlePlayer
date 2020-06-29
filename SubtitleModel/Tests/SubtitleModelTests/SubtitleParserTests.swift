import FoundationExtensions
import FunctionalParser
@testable import SubtitleModel
import XCTest

final class SubtitleParserTests: XCTestCase {
    func testParserSingleLineAndSomeLineBreaks() throws {
        let string = """
                     1
                     00:00:16,950 --> 00:00:19,082
                     Amigo, isso só vai demorar um instante.


                     """
        let subtitle = try Subtitle.from(string: string).get()
        XCTAssertEqual(subtitle.lines.count, 1)
        assertItIsFirstLineSingleLineTests(subtitle.lines[safe: 0])
    }

    func testParserTwoLines() throws {
        let string = """
                     1
                     00:00:16,950 --> 00:00:19,082
                     Amigo, isso só vai demorar um instante.

                     2
                     00:00:19,153 --> 00:00:20,998
                     Queremos inspecionar seu caminhão.

                     """
        let subtitle = try Subtitle.from(string: string).get()
        XCTAssertEqual(subtitle.lines.count, 2)
        assertItIsFirstLineSingleLineTests(subtitle.lines[safe: 0])
        assertItIsSecondLineSingleLineTests(subtitle.lines[safe: 1])
    }

    func assertItIsFirstLineSingleLineTests(_ line: Subtitle.Line?) {
        XCTAssertEqual(line?.sequence, 1)
        XCTAssertEqual(line?.start, Time(hours: 0, minutes: 0, seconds: 16, milliseconds: 950))
        XCTAssertEqual(line?.end, Time(hours: 0, minutes: 0, seconds: 19, milliseconds: 82))
        XCTAssertEqual(line?.text, "Amigo, isso só vai demorar um instante.")
    }

    func assertItIsSecondLineSingleLineTests(_ line: Subtitle.Line?) {
        XCTAssertEqual(line?.sequence, 2)
        XCTAssertEqual(line?.start, Time(hours: 0, minutes: 0, seconds: 19, milliseconds: 153))
        XCTAssertEqual(line?.end, Time(hours: 0, minutes: 0, seconds: 20, milliseconds: 998))
        XCTAssertEqual(line?.text, "Queremos inspecionar seu caminhão.")
    }
}

extension SubtitleParserTests {
    func testParserMultilineText() throws {
        let string = """
                     1
                     00:06:03,538 --> 00:06:05,245
                     A partir da aparência da

                     ferida deste jovem rapaz,

                     2
                     00:06:05,274 --> 00:06:09,537
                     eu diria que ele provavelmente foi
                     atingido por uma bala do mesmo rifle.

                     3
                     00:06:10,039 --> 00:06:13,043
                     É bom ter bastante cuidado
                     com essa ferida.

                     """
        let subtitle = try Subtitle.from(string: string).get()

        XCTAssertEqual(subtitle.lines.count, 3)
        assertItIsFirstLineMultiLineTests(subtitle.lines[safe: 0])
        assertItIsSecondLineMultiLineTests(subtitle.lines[safe: 1])
        assertItIsThirdLineMultiLineTests(subtitle.lines[safe: 2])
    }

    func testParserMultilineTextWindowsLineBreak() throws {
        let string = "1\r\n" +
                     "00:06:03,538 --> 00:06:05,245\r\n" +
                     "A partir da aparência da\r\n" +
                     "\r\n" +
                     "ferida deste jovem rapaz,\r\n" +
                     "\r\n" +
                     "\r\n" +
                     "2\r\n" +
                     "00:06:05,274 --> 00:06:09,537\r\n" +
                     "eu diria que ele provavelmente foi\r\n" +
                     "atingido por uma bala do mesmo rifle.\r\n" +
                     "\r\n" +
                     "3\r\n" +
                     "00:06:10,039 --> 00:06:13,043\r\n" +
                     "É bom ter bastante cuidado\r\n" +
                     "com essa ferida.\r\n" +
                     "\r\n" +
                     "\r\n"
        let subtitle = try Subtitle.from(string: string).get()

        XCTAssertEqual(subtitle.lines.count, 3)
        assertItIsFirstLineMultiLineTests(subtitle.lines[safe: 0])
        assertItIsSecondLineMultiLineTests(subtitle.lines[safe: 1])
        assertItIsThirdLineMultiLineTests(subtitle.lines[safe: 2])
    }

    func assertItIsFirstLineMultiLineTests(_ line: Subtitle.Line?) {
        XCTAssertEqual(line?.sequence, 1)
        XCTAssertEqual(line?.start, Time(hours: 0, minutes: 6, seconds: 3, milliseconds: 538))
        XCTAssertEqual(line?.end, Time(hours: 0, minutes: 6, seconds: 5, milliseconds: 245))
        XCTAssertEqual(line?.text, "A partir da aparência da\n\nferida deste jovem rapaz,")
    }

    func assertItIsSecondLineMultiLineTests(_ line: Subtitle.Line?) {
        XCTAssertEqual(line?.sequence, 2)
        XCTAssertEqual(line?.start, Time(hours: 0, minutes: 6, seconds: 5, milliseconds: 274))
        XCTAssertEqual(line?.end, Time(hours: 0, minutes: 6, seconds: 9, milliseconds: 537))
        XCTAssertEqual(line?.text, "eu diria que ele provavelmente foi\natingido por uma bala do mesmo rifle.")
    }

    func assertItIsThirdLineMultiLineTests(_ line: Subtitle.Line?) {
        XCTAssertEqual(line?.sequence, 3)
        XCTAssertEqual(line?.start, Time(hours: 0, minutes: 6, seconds: 10, milliseconds: 39))
        XCTAssertEqual(line?.end, Time(hours: 0, minutes: 6, seconds: 13, milliseconds: 43))
        XCTAssertEqual(line?.text, "É bom ter bastante cuidado\ncom essa ferida.")
    }
}
