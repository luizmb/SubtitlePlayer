import Foundation

public enum SubtitleEvent {
    case entry(offset: Double, text: String)
    case exit(offset: Double, text: String)
}

extension SubtitleEvent {
    public var offset: Double {
        switch self {
        case let .entry(offset, _), let .exit(offset, _): return offset
        }
    }

    public var text: String {
        switch self {
        case let .entry(_, text), let .exit(_, text): return text
        }
    }
}
