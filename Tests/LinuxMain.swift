import XCTest

import subtTests
import SubtitlePlayerTests

var tests = [XCTestCaseEntry]()
tests += subtTests.allTests()
tests += SubtitlePlayerTests.allTests()
XCTMain(tests)
