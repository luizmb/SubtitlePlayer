import XCTest

import subtTests

var tests = [XCTestCaseEntry]()
tests += subtTests.allTests()
XCTMain(tests)
