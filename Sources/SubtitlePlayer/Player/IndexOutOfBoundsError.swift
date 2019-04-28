import Foundation

public struct IndexOutOfBoundsError: Error {
    public let providedIndex: Int
    public init(providedIndex: Int) {
        self.providedIndex = providedIndex
    }
}
