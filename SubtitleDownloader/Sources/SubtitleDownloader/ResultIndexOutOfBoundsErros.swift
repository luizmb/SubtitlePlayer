import Foundation

public struct ResultIndexOutOfBoundsError: Error, Equatable {
    public let index: Int
    public init(index: Int) {
        self.index = index
    }
}
