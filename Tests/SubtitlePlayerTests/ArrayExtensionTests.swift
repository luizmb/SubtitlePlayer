import SubtitlePlayer
import XCTest

final class ArrayExtensionsTests: XCTestCase {
    func testSafeSubcriptGetSuccess() {
        // given
        let array = [1, 2, 3, 4]

        // when
        let sut = array[safe: 2]

        // then
        XCTAssertEqual(3, sut)
    }

    func testSafeSubcriptSetSuccess() {
        // given
        var array = [1, 2, 3, 4]

        // when
        array[safe: 2] = 42

        // then
        XCTAssertEqual([1, 2, 42, 4], array)
    }

    func testSafeSubcriptGetNegative() {
        // given
        let array = [1, 2, 3, 4]

        // when
        let sut = array[safe: -2]

        // then
        XCTAssertNil(sut)
    }

    func testSafeSubcriptSetNegative() {
        // given
        var array = [1, 2, 3, 4]

        // when
        array[safe: -2] = 42

        // then
        XCTAssertEqual([1, 2, 3, 4], array)
    }

    func testSafeSubcriptGetOutOfBounds() {
        // given
        let array = [1, 2, 3, 4]

        // when
        let sut = array[safe: 4]

        // then
        XCTAssertNil(sut)
    }

    func testSafeSubcriptSetOutOfBounds() {
        // given
        var array = [1, 2, 3, 4]

        // when
        array[safe: 4] = 42

        // then
        XCTAssertEqual([1, 2, 3, 4], array)
    }

    func testRemoveSafeSubcriptSuccess() {
        // given
        var array = [1, 2, 3, 4]

        // when
        let sut = array.removeSafe(at: 2)

        // then
        XCTAssertEqual([1, 2, 4], array)
        XCTAssertEqual(3, sut)
    }

    func testRemoveSafeSubcriptNegative() {
        // given
        var array = [1, 2, 3, 4]

        // when
        let sut = array.removeSafe(at: -2)

        // then
        XCTAssertEqual([1, 2, 3, 4], array)
        XCTAssertNil(sut)
    }

    func testRemoveSafeSubcriptOutOfBounds() {
        // given
        var array = [1, 2, 3, 4]

        // when
        let sut = array.removeSafe(at: 4)

        // then
        XCTAssertEqual([1, 2, 3, 4], array)
        XCTAssertNil(sut)
    }

    static var allTests = [
        ("testSafeSubcriptGetSuccess", testSafeSubcriptGetSuccess),
        ("testSafeSubcriptSetSuccess", testSafeSubcriptSetSuccess),
        ("testSafeSubcriptGetNegative", testSafeSubcriptGetNegative),
        ("testSafeSubcriptSetNegative", testSafeSubcriptSetNegative),
        ("testSafeSubcriptGetOutOfBounds", testSafeSubcriptGetOutOfBounds),
        ("testSafeSubcriptSetOutOfBounds", testSafeSubcriptSetOutOfBounds),
        ("testRemoveSafeSubcriptSuccess", testRemoveSafeSubcriptSuccess),
        ("testRemoveSafeSubcriptNegative", testRemoveSafeSubcriptNegative),
        ("testRemoveSafeSubcriptOutOfBounds", testRemoveSafeSubcriptOutOfBounds)
    ]
}
