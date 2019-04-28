import Foundation

public struct MovieInfo {
    let byteSize: Int
    let hash: String

    public init?(byteSize: Int, hash: String) {
        guard MovieInfo.isValid(hash: hash) else { return nil }
        self.byteSize = byteSize
        self.hash = hash
    }

    public static func isValid(hash: String) -> Bool {
        return hash.count == 16 && hash.range(of: #"\b[a-fA-F\d]{16}\b"#, options: .regularExpression) != nil
    }
}
