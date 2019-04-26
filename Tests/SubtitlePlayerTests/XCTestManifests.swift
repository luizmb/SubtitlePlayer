import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ArrayExtensionTests.allTests),
        testCase(TimeTests.allTests)
    ]
}
#endif
