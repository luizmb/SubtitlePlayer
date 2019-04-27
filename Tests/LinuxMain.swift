import XCTest

import subtTests
import CommonTests
import SubtitlePlayerTests

var tests = [XCTestCaseEntry]()
tests += subtTests.allTests()
tests += SubtitlePlayerTests.allTests()
tests += CommonTests.allTests()
XCTMain(tests)
