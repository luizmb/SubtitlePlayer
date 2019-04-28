import Common
import Foundation
import RxSwift

public class SubtitlePlayer {
    private let subtitle: Subtitle

    public init(subtitle: Subtitle) {
        self.subtitle = subtitle
    }

    public func playFromBeggining() -> Observable<[Subtitle.Line]> {
        return playEvents(from: 0, lines: [.init(sequence: 0, start: .zero, end: .zero, text: "")] + subtitle.lines).scanSubtitle()
    }

    public func play(from index: Int) -> Observable<[Subtitle.Line]> {
        return playEvents(from: index, lines: subtitle.lines).scanSubtitle()
    }
}

extension Observable where Element == SubtitleEvent {
    public func scanSubtitle() -> Observable<[Subtitle.Line]> {
        return scan([Subtitle.Line](), accumulator: { (accumulator, event) -> [Subtitle.Line] in
            switch event {
            case let .entry(_, line): return accumulator + [line]
            case let .exit(_, line): return accumulator.filter { $0 != line }
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
                    SubtitleEvent.entry(offset: line.start.totalSeconds - referenceStart, line: line),
                    SubtitleEvent.exit(offset: line.end.totalSeconds - referenceStart, line: line),
                ]
            }
    )
}
