import Common
import Foundation
import RxSwift

public class SubtitlePlayer {
    private let subtitle: Subtitle

    init(subtitle: Subtitle) {
        self.subtitle = subtitle
    }

    func play(from sequence: Int = 0) -> Observable<[Subtitle.Line]> {
        return playEvents(from: sequence, lines: [.init(sequence: 0, start: .zero, end: .zero, text: "")] + subtitle.lines).scanSubtitle()
    }
}

extension SubtitlePlayer {
    public static func play(subtitle: Subtitle, from sequence: Int = 0) -> Observable<[Subtitle.Line]> {
        return SubtitlePlayer(subtitle: subtitle).play(from: sequence)
    }

    public static func play(data: Data, encoding: String.Encoding, from sequence: Int = 0) -> Observable<[Subtitle.Line]> {
        return Subtitle
            .from(data: data, encoding: encoding)
            .fold(
                ifSuccess: { play(subtitle: $0, from: sequence) },
                ifFailure: { .error($0) }
            )
    }

    public static func play(string: String, from sequence: Int = 0) -> Observable<[Subtitle.Line]> {
        return Subtitle
            .from(string: string)
            .fold(
                ifSuccess: { play(subtitle: $0, from: sequence) },
                ifFailure: { .error($0) }
            )
    }

    public static func play(filePath: String, encoding: String.Encoding, from sequence: Int = 0) -> Reader<FileManagerProtocol, Observable<[Subtitle.Line]>> {
        return Subtitle
            .from(filePath: filePath, encoding: encoding)
            .map {
                $0.fold(
                    ifSuccess: { play(subtitle: $0, from: sequence) },
                    ifFailure: { .error($0) }
                )
            }
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

private func playEvents(from sequence: Int, lines: [Subtitle.Line]) -> Observable<SubtitleEvent> {
    return getEvents(from: sequence, lines: lines)
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

private func getEvents(from sequence: Int, lines: [Subtitle.Line]) -> Result<[SubtitleEvent], Error> {
    guard let referenceStart = lines.first(where: { $0.sequence == sequence })?.start.totalSeconds else {
        return .failure(SequenceOutOfBoundsError(sequenceNumber: sequence))
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
