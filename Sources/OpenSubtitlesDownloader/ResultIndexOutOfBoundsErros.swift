import Foundation

public struct ResultIndexOutOfBoundsError: Error {
    public let index: Int
    public init(index: Int) {
        self.index = index
    }
}
