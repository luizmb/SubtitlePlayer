import Foundation

public protocol GzipProtocol {
    static func compress(_ data: Data) -> Result<Data, Error>
    static func decompress(_ data: Data) -> Result<Data, Error>
}
