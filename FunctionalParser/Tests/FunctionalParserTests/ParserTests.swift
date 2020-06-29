@testable import FunctionalParser
import XCTest

final class SubtitleParserTests: XCTestCase {
    func testParserLiteral() throws {
        let string = "1"
        let result = Parser.literal("1").run(string)
        let match: Void? = result.match
        let rest = result.rest
        XCTAssertNotNil(match)
        XCTAssertTrue(rest.isEmpty)
    }

    func testParserLiteralFail() throws {
        let string = "2"
        let result = Parser.literal("1").run(string)
        let match: Void? = result.match
        let rest = result.rest
        XCTAssertNil(match)
        XCTAssertEqual(String(rest), "2")
    }

    func testParserLiteralTwoChars() throws {
        let string = "123"
        let result = Parser.literal("12").run(string)
        let match: Void? = result.match
        let rest = result.rest
        XCTAssertNotNil(match)
        XCTAssertEqual("3", String(rest))
    }

    func testParserLiteralComposedUnicode() throws {
        let string = "\r\n1"
        let result = Parser.literal("\r\n").run(string)
        let match: Void? = result.match
        let rest = result.rest
        XCTAssertNotNil(match)
        XCTAssertEqual("1", String(rest))
    }

    func testParserLiteralZip() throws {
        let string = "12345"
        let result = Parser.zip(.literal("12"), .literal("34")).run(string)
        let match: (Void, Void)? = result.match
        let rest = result.rest
        XCTAssertNotNil(match)
        XCTAssertEqual("5", String(rest))
    }

    func testParserOneOrMoreSpaces() throws {
        let string = "1 2 3"
        let result = Parser.zip(
            .literal("1"),
            .oneOrMoreSpaces,
            .literal("2"),
            .oneOrMoreSpaces,
            .literal("3")
        ).run(string)

        let match = result.match
        let rest = result.rest
        XCTAssertNotNil(match)
        XCTAssertTrue(rest.isEmpty)
    }

    func testParserOneOrMoreSpacesFail() throws {
        let string = "1 23"
        let result = Parser.zip(
            .literal("1"),
            .oneOrMoreSpaces,
            .literal("2"),
            .oneOrMoreSpaces,
            .literal("3")
        ).run(string)

        let match = result.match
        let rest = result.rest
        XCTAssertNil(match)
        XCTAssertEqual(string, String(rest))
    }

    func testParserZeroOrMoreSpaces() throws {
        let string = "1 23"
        let result = Parser.zip(
            .literal("1"),
            .zeroOrMoreSpaces,
            .literal("2"),
            .zeroOrMoreSpaces,
            .literal("3")
        ).run(string)

        let match = result.match
        let rest = result.rest
        XCTAssertNotNil(match)
        XCTAssertTrue(rest.isEmpty)
    }

    func testParserZeroOrMoreSpacesBeginning() throws {
        let string = "1 23"
        let result = Parser.zip(
            .zeroOrMoreSpaces,
            .literal("1"),
            .zeroOrMoreSpaces,
            .literal("2"),
            .zeroOrMoreSpaces,
            .literal("3")
        ).run(string)

        let match = result.match
        let rest = result.rest
        XCTAssertNotNil(match)
        XCTAssertTrue(rest.isEmpty)
    }

    func testParserZeroOrMoreSpacesEnd() throws {
        let string = "1 23"
        let result = Parser.zip(
            .literal("1"),
            .zeroOrMoreSpaces,
            .literal("2"),
            .zeroOrMoreSpaces,
            .literal("3"),
            .zeroOrMoreSpaces
        ).run(string)

        let match = result.match
        let rest = result.rest
        XCTAssertNotNil(match)
        XCTAssertTrue(rest.isEmpty)
    }

    func testOneOf() throws {
        let string1 = "1ab"
        let string2 = "2ab"
        let string3 = "3ab"

        let sut = Parser.oneOf([.literal("1"), .literal("2")])

        let result1 = sut.run(string1)
        let result2 = sut.run(string2)
        let result3 = sut.run(string3)

        XCTAssertNotNil(result1.match)
        XCTAssertNotNil(result2.match)
        XCTAssertNil(result3.match)

        XCTAssertEqual("ab", String(result1.rest))
        XCTAssertEqual("ab", String(result2.rest))
        XCTAssertEqual("3ab", String(result3.rest))
    }

    func testLineBreak() throws {
        let string1 = "1\nab"
        let string2 = "1\r\nab"
        let string3 = "1\rab"
        let string4 = "1 ab"

        let sut = Parser.zip(.literal("1"), .lineBreak)

        let result1 = sut.run(string1)
        let result2 = sut.run(string2)
        let result3 = sut.run(string3)
        let result4 = sut.run(string4)

        XCTAssertNotNil(result1.match)
        XCTAssertNotNil(result2.match)
        XCTAssertNotNil(result3.match)
        XCTAssertNil(result4.match)

        XCTAssertEqual("ab", String(result1.rest))
        XCTAssertEqual("ab", String(result2.rest))
        XCTAssertEqual("ab", String(result3.rest))
        XCTAssertEqual("1 ab", String(result4.rest))
    }

    func testParserSpaceAndLineBreak() throws {
        let string = " \ntest"
        let sut = Parser.zip(.oneOrMoreSpaces, .lineBreak)
        let result = sut.run(string)
        XCTAssertNotNil(result.match)
        XCTAssertEqual("test", String(result.rest))
    }
}
