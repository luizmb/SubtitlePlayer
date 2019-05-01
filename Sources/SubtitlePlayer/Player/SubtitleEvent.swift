import Foundation

public enum SubtitleEvent {
    case entry(offset: DispatchTimeInterval, line: Subtitle.Line)
    case exit(offset: DispatchTimeInterval, line: Subtitle.Line)
}

extension SubtitleEvent {
    public var offset: DispatchTimeInterval {
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
