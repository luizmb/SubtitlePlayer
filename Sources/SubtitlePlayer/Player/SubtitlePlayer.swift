import Common
import Foundation
import RxSwift

public class SubtitlePlayer {
    private let subtitle: Subtitle

    init(subtitle: Subtitle) {
        self.subtitle = subtitle
    }

    public func play(triggerTime: Date,
                     startingLine: Int,
                     now: Date) -> Observable<SubtitleEvent> {
        guard startingLine != 0 else {
            return play(triggerTime: triggerTime, offset: 0, now: now)
        }

        guard let offset = subtitle.lines.first(where: { $0.sequence == startingLine })?.start.totalSeconds else {
            return .error(SequenceOutOfBoundsError(sequenceNumber: startingLine))
        }

        return play(triggerTime: triggerTime, offset: offset, now: now)
    }

    public func play(triggerTime: Date,
                     offset: TimeInterval,
                     now: Date) -> Observable<SubtitleEvent> {
        return Observable<SubtitleEvent>
            .from(
                getEvents(triggerTime: triggerTime, offset: offset, now: now, lines: subtitle.lines)
            ).flatMap { event in
                Observable<SubtitleEvent>
                    .just(event)
                    .delay(event.offset, scheduler: MainScheduler.instance)
            }
    }
}

extension SubtitlePlayer {
    public static func play(subtitle: Subtitle,
                            triggerTime: Date,
                            startingLine: Int,
                            now: Date) -> Observable<[Subtitle.Line]> {
        return SubtitlePlayer(subtitle: subtitle)
            .play(triggerTime: triggerTime, startingLine: startingLine, now: now).scanSubtitle()
    }

    public static func play(subtitle: Subtitle,
                            triggerTime: Date,
                            offset: TimeInterval,
                            now: Date) -> Observable<[Subtitle.Line]> {
        return SubtitlePlayer(subtitle: subtitle)
            .play(triggerTime: triggerTime, offset: offset, now: now).scanSubtitle()
    }
}

extension SubtitlePlayer {
    public static func play(data: Data,
                            encoding: String.Encoding,
                            triggerTime: Date,
                            startingLine: Int,
                            now: Date) -> Observable<[Subtitle.Line]> {
        return Subtitle
            .from(data: data, encoding: encoding)
            .fold(
                ifSuccess: { play(subtitle: $0, triggerTime: triggerTime, startingLine: startingLine, now: now) },
                ifFailure: { .error($0) }
            )
    }

    public static func play(data: Data,
                            encoding: String.Encoding,
                            triggerTime: Date,
                            offset: TimeInterval,
                            now: Date) -> Observable<[Subtitle.Line]> {
        return Subtitle
            .from(data: data, encoding: encoding)
            .fold(
                ifSuccess: { play(subtitle: $0, triggerTime: triggerTime, offset: offset, now: now) },
                ifFailure: { .error($0) }
        )
    }
}

extension SubtitlePlayer {
    public static func play(string: String,
                            triggerTime: Date,
                            startingLine: Int,
                            now: Date) -> Observable<[Subtitle.Line]> {
        return Subtitle
            .from(string: string)
            .fold(
                ifSuccess: { play(subtitle: $0, triggerTime: triggerTime, startingLine: startingLine, now: now) },
                ifFailure: { .error($0) }
        )
    }

    public static func play(string: String,
                            triggerTime: Date,
                            offset: TimeInterval,
                            now: Date) -> Observable<[Subtitle.Line]> {
        return Subtitle
            .from(string: string)
            .fold(
                ifSuccess: { play(subtitle: $0, triggerTime: triggerTime, offset: offset, now: now) },
                ifFailure: { .error($0) }
        )
    }
}

extension SubtitlePlayer {
    public static func play(filePath: String,
                            encoding: String.Encoding,
                            triggerTime: Date,
                            startingLine: Int,
                            now: Date) -> Reader<FileManagerProtocol, Observable<[Subtitle.Line]>> {
        return Subtitle
            .from(filePath: filePath, encoding: encoding)
            .map {
                $0.fold(
                    ifSuccess: { play(subtitle: $0, triggerTime: triggerTime, startingLine: startingLine, now: now) },
                    ifFailure: { .error($0) }
                )
            }
    }

    public static func play(filePath: String,
                            encoding: String.Encoding,
                            triggerTime: Date,
                            offset: TimeInterval,
                            now: Date) -> Reader<FileManagerProtocol, Observable<[Subtitle.Line]>> {
        return Subtitle
            .from(filePath: filePath, encoding: encoding)
            .map {
                $0.fold(
                    ifSuccess: { play(subtitle: $0, triggerTime: triggerTime, offset: offset, now: now) },
                    ifFailure: { .error($0) }
                )
            }
    }
}

private func getEvents(triggerTime: Date,
                       offset: TimeInterval,
                       now: Date,
                       lines: [Subtitle.Line]) -> [SubtitleEvent] {
    //           trigger:  "21:30:00"
    //            offset:  "00:02:11"
    //               now:  "22:00:00"
    //       currentTime:  "00:32:11"
    // ------------------------------
    // line not included:  "00:32:05" -> offset: -"00:00:06"
    //     line included:  "00:32:15" -> offset:  "00:00:04"
    let currentTimeInMilli = (now.timeIntervalSince(triggerTime) + offset) * 1000

    return ([.init(sequence: 0, start: .zero, end: .zero, text: "")] + lines)
        .reduce(into: [SubtitleEvent]()) { events, line in
            let entryFromNow = Int(max(line.start.totalMilliseconds - currentTimeInMilli, 0))
            let exitFromNow = Int(line.end.totalMilliseconds - currentTimeInMilli)
            guard exitFromNow > 0 else { return }
            events.append(contentsOf: [
                .entry(offset: .milliseconds(entryFromNow), line: line),
                .exit(offset: .milliseconds(exitFromNow), line: line)
            ])
    }
}

extension Observable where Element == SubtitleEvent {
    public func scanSubtitle() -> Observable<[Subtitle.Line]> {
        return scan([Subtitle.Line](), accumulator: { (accumulator, event) -> [Subtitle.Line] in
            switch event {
            case let .entry(_, line): return accumulator + [line]
            case let .exit(_, line): return accumulator.filter { $0.sequence != line.sequence }
            }
        })
    }
}
