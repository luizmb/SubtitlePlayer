import Foundation
extension String {
    public func leading(char: Character, toLength: Int) -> String {
        let toAdd = toLength - count
        guard toAdd > 0 else { return self }
        return (Array(repeating: String(char), count: toAdd) + [self]).joined()
    }

    public func trailing(char: Character, toLength: Int) -> String {
        let toAdd = toLength - count
        guard toAdd > 0 else { return self }
        return ([self] + Array(repeating: String(char), count: toAdd)).joined()
    }
}
