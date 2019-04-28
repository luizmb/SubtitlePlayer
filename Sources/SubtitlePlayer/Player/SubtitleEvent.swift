import Foundation

public enum SubtitleEvent {
    case entry(offset: Double, line: Subtitle.Line)
    case exit(offset: Double, line: Subtitle.Line)
}

extension SubtitleEvent {
    public var offset: Double {
        switch self {
        case let .entry(offset, _), let .exit(offset, _): return offset
        }
    }

    public var line: Subtitle.Line {
        switch self {
        case let .entry(_, line), let .exit(_, line): return line
        }
    }
}
