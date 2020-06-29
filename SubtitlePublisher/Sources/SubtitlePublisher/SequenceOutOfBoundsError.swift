import Foundation

public struct SequenceOutOfBoundsError: Error {
    public let sequenceNumber: Int
    public init(sequenceNumber: Int) {
        self.sequenceNumber = sequenceNumber
    }
}
