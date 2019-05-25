import Common
import Foundation
import RxSwift

public class SubtitlePlayer {
    private let subtitle: Subtitle

    init(subtitle: Subtitle) {
        self.subtitle = subtitle
    }

    public func play(triggerTime: DispatchTime,
                     startingLine: Int,
                     now: DispatchTime) -> Observable<SubtitleEvent> {
        guard startingLine != 0 else {
            return play(triggerTime: triggerTime, offset: .milliseconds(0), now: now)
        }

        guard let offset = subtitle.lines.first(where: { $0.sequence == startingLine })?.start.totalMilliseconds else {
            return .error(SequenceOutOfBoundsError(sequenceNumber: startingLine))
        }

        return play(triggerTime: triggerTime, offset: .milliseconds(Int(offset)), now: now)
    }

    public func play(triggerTime: DispatchTime,
                     offset: DispatchTimeInterval,
                     now: DispatchTime) -> Observable<SubtitleEvent> {
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
                            triggerTime: DispatchTime,
                            startingLine: Int,
                            now: DispatchTime) -> Observable<[Subtitle.Line]> {
        return SubtitlePlayer(subtitle: subtitle)
            .play(triggerTime: triggerTime, startingLine: startingLine, now: now).scanSubtitle()
    }

    public static func play(subtitle: Subtitle,
                            triggerTime: DispatchTime,
                            offset: DispatchTimeInterval,
                            now: DispatchTime) -> Observable<[Subtitle.Line]> {
        return SubtitlePlayer(subtitle: subtitle)
            .play(triggerTime: triggerTime, offset: offset, now: now).scanSubtitle()
    }
}

extension SubtitlePlayer {
    public static func play(data: Data,
                            encoding: String.Encoding,
                            triggerTime: DispatchTime,
                            startingLine: Int,
                            now: DispatchTime) -> Observable<[Subtitle.Line]> {
        return Subtitle
            .from(data: data, encoding: encoding)
            .fold(
                ifSuccess: { play(subtitle: $0, triggerTime: triggerTime, startingLine: startingLine, now: now) },
                ifFailure: { .error($0) }
            )
    }

    public static func play(data: Data,
                            encoding: String.Encoding,
                            triggerTime: DispatchTime,
                            offset: DispatchTimeInterval,
                            now: DispatchTime) -> Observable<[Subtitle.Line]> {
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
                            triggerTime: DispatchTime,
                            startingLine: Int,
                            now: DispatchTime) -> Observable<[Subtitle.Line]> {
        return Subtitle
            .from(string: string)
            .fold(
                ifSuccess: { play(subtitle: $0, triggerTime: triggerTime, startingLine: startingLine, now: now) },
                ifFailure: { .error($0) }
        )
    }

    public static func play(string: String,
                            triggerTime: DispatchTime,
                            offset: DispatchTimeInterval,
                            now: DispatchTime) -> Observable<[Subtitle.Line]> {
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
                            triggerTime: DispatchTime,
                            startingLine: Int,
                            now: DispatchTime) -> Reader<FileManagerProtocol, Observable<[Subtitle.Line]>> {
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
                            triggerTime: DispatchTime,
                            offset: DispatchTimeInterval,
                            now: DispatchTime) -> Reader<FileManagerProtocol, Observable<[Subtitle.Line]>> {
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

private func getEvents(triggerTime: DispatchTime,
                       offset: DispatchTimeInterval,
                       now: DispatchTime,
                       lines: [Subtitle.Line]) -> [SubtitleEvent] {
    //           trigger:  "21:30:00"
    //            offset:  "00:05:00"
    //         movieZero:  "21:25:00"
    //               now:  "22:00:00"
    // ------------------------------
    // line not included:  "00:34:55"
    //     line included:  "00:35:01"
    let movieZeroMark = triggerTime - offset // 21:30:00 - 00:05:00 = 21:25:00
    let currentTimeInMilli = Double(now.uptimeNanoseconds - movieZeroMark.uptimeNanoseconds) * 1e-6 // 22:00:00 - 21:25:00 = 00:35:00

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
