import Foundation

public enum HTTPMethod: String, CustomDebugStringConvertible {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case put = "PUT"

    public var description: String {
        return self.rawValue
    }

    public var debugDescription: String {
        return self.rawValue
    }
}
