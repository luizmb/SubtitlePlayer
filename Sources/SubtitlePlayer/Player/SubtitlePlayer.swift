import Common
import Foundation
import RxSwift

public class SubtitlePlayer {
    private let subtitle: Subtitle

    public init(subtitle: Subtitle) {
        self.subtitle = subtitle
    }

    public func playFromBeggining() -> Observable<[String]> {
        return playEvents(from: 0, lines: [.init(start: .zero, end: .zero, text: "")] + subtitle.lines).scanText()
    }

    public func play(from index: Int) -> Observable<[String]> {
        return playEvents(from: index, lines: subtitle.lines).scanText()
    }
}

extension Observable where Element == SubtitleEvent {
    public func scanText() -> Observable<[String]> {
        return scan([String](), accumulator: { (strings, event) -> [String] in
            switch event {
            case let .entry(_, text): return strings + [text]
            case let .exit(_, text): return strings.filter { $0 != text }
            }
        })
    }
}

private func playEvents(from index: Int, lines: [Subtitle.Line]) -> Observable<SubtitleEvent> {
    return getEvents(from: index, lines: lines)
        .fold(
            ifSuccess: {
                Observable<SubtitleEvent>
                    .from($0, scheduler: MainScheduler.instance)
                    .flatMap { event in
                        Observable<SubtitleEvent>.just(event).delay(event.offset, scheduler: MainScheduler.instance)
                    }
            },
            ifFailure: Observable<SubtitleEvent>.error
    )
}

private func getEvents(from index: Int, lines: [Subtitle.Line]) -> Result<[SubtitleEvent], Error> {
    guard let referenceStart = lines[safe: index]?.start.totalSeconds else {
        return .failure(IndexOutOfBoundsError(providedIndex: index))
    }

    return .success (
        lines
            .lazy
            .filter { line in line.start.totalSeconds - referenceStart >= 0 }
            .reduce([SubtitleEvent]()) { events, line in
                events + [
                    SubtitleEvent.entry(offset: line.start.totalSeconds - referenceStart, text: line.text),
                    SubtitleEvent.exit(offset: line.end.totalSeconds - referenceStart, text: line.text),
                ]
            }
    )
}
