import Foundation

public struct ImdbId: RawRepresentable {
    public var rawValue: String

    public init?(rawValue: String) {
        guard ImdbId.isValid(rawValue) else { return nil }
        self.rawValue = rawValue
    }

    public static func isValid(_ string: String) -> Bool {
        return string.count == 7 && string.range(of: #"\b\d{7}\b"#, options: .regularExpression) != nil
    }
}
