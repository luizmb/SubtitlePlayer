import Combine
import Foundation
import FoundationExtensions
import SubtitleModel

public struct SubtitlePlayer {
    private let subtitle: Subtitle

    init(subtitle: Subtitle) {
        self.subtitle = subtitle
    }

    public func play(triggerTime: Date,
                     startingLine: Int,
                     now: Date) -> AnyPublisher<SubtitleEvent, PlayerError> {
        guard startingLine != 0 else {
            return play(triggerTime: triggerTime, offset: 0, now: now).setFailureType(to: PlayerError.self).eraseToAnyPublisher()
        }

        guard let offset = subtitle.lines.first(where: { $0.sequence == startingLine })?.start.totalSeconds else {
            return Fail<SubtitleEvent, PlayerError>(
                error: PlayerError.indexOutOfBounds(SequenceOutOfBoundsError(sequenceNumber: startingLine))
            ).eraseToAnyPublisher()
        }

        return play(triggerTime: triggerTime, offset: offset, now: now).setFailureType(to: PlayerError.self).eraseToAnyPublisher()
    }

    public func play(triggerTime: Date,
                     offset: TimeInterval,
                     now: Date) -> AnyPublisher<SubtitleEvent, Never> {
        getEvents(triggerTime: triggerTime, offset: offset, now: now, lines: subtitle.lines)
            .publisher
            .flatMap { event in
                Just(event)
                    .delay(for: .init(event.offset), scheduler: DispatchQueue.main)
            }
            .eraseToAnyPublisher()
    }
}
extension SubtitlePlayer {
    public static func play(subtitle: Subtitle,
                            triggerTime: Date,
                            startingLine: Int,
                            now: Date) -> AnyPublisher<[Subtitle.Line], PlayerError> {
        SubtitlePlayer(subtitle: subtitle)
            .play(triggerTime: triggerTime, startingLine: startingLine, now: now).scanSubtitle()
    }

    public static func play(subtitle: Subtitle,
                            triggerTime: Date,
                            offset: TimeInterval,
                            now: Date) -> AnyPublisher<[Subtitle.Line], Never> {
        SubtitlePlayer(subtitle: subtitle)
            .play(triggerTime: triggerTime, offset: offset, now: now).scanSubtitle()
    }
}

extension SubtitlePlayer {
    public static func play(data: Data,
                            encoding: String.Encoding,
                            triggerTime: Date,
                            startingLine: Int,
                            now: Date) -> AnyPublisher<[Subtitle.Line], PlayerError> {
        Subtitle
            .from(data: data, encoding: encoding)
            .fold(
                onSuccess: {
                    play(subtitle: $0, triggerTime: triggerTime, startingLine: startingLine, now: now).mapError(identity).eraseToAnyPublisher()
                },
                onFailure: { Fail<[Subtitle.Line], PlayerError>(error: .decodingError($0)).eraseToAnyPublisher() }
            )
    }

    public static func play(data: Data,
                            encoding: String.Encoding,
                            triggerTime: Date,
                            offset: TimeInterval,
                            now: Date) -> AnyPublisher<[Subtitle.Line], PlayerError> {
        Subtitle
            .from(data: data, encoding: encoding)
            .fold(
                onSuccess: { play(subtitle: $0, triggerTime: triggerTime, offset: offset, now: now).mapError(absurd).eraseToAnyPublisher() },
                onFailure: { Fail<[Subtitle.Line], PlayerError>(error: .decodingError($0)).eraseToAnyPublisher() }
        )
    }
}

extension SubtitlePlayer {
    public static func play(string: String,
                            triggerTime: Date,
                            startingLine: Int,
                            now: Date) -> AnyPublisher<[Subtitle.Line], PlayerError> {
        Subtitle
            .from(string: string)
            .fold(
                onSuccess: { play(subtitle: $0, triggerTime: triggerTime, startingLine: startingLine, now: now).mapError(identity).eraseToAnyPublisher() },
                onFailure: { Fail<[Subtitle.Line], PlayerError>(error: .decodingError($0)).eraseToAnyPublisher() }
            )
    }

    public static func play(string: String,
                            triggerTime: Date,
                            offset: TimeInterval,
                            now: Date) -> AnyPublisher<[Subtitle.Line], PlayerError> {
        Subtitle
            .from(string: string)
            .fold(
                onSuccess: { play(subtitle: $0, triggerTime: triggerTime, offset: offset, now: now).mapError(absurd).eraseToAnyPublisher() },
                onFailure: { Fail<[Subtitle.Line], PlayerError>(error: .decodingError($0)).eraseToAnyPublisher() }
            )
    }
}

public enum PlayerError: Error {
    case indexOutOfBounds(SequenceOutOfBoundsError)
    case decodingError(SubtitleDecodingError)
}

extension SubtitlePlayer {
    public static func play(filePath: String,
                            encoding: String.Encoding,
                            triggerTime: Date,
                            startingLine: Int,
                            now: Date) -> Reader<ReadFileAtPath, AnyPublisher<[Subtitle.Line], PlayerError>> {
        Subtitle
            .from(filePath: filePath, encoding: encoding)
            .mapValue { result in
                result.fold(
                    onSuccess: { play(subtitle: $0, triggerTime: triggerTime, startingLine: startingLine, now: now).eraseToAnyPublisher() },
                    onFailure: { error in Fail<[Subtitle.Line], PlayerError>(error: .decodingError(error)).eraseToAnyPublisher() }
                )
            }
    }

    public static func play(filePath: String,
                            encoding: String.Encoding,
                            triggerTime: Date,
                            offset: TimeInterval,
                            now: Date) -> Reader<ReadFileAtPath, AnyPublisher<[Subtitle.Line], PlayerError>> {
        Subtitle
            .from(filePath: filePath, encoding: encoding)
            .mapValue { result in
                result.fold(
                    onSuccess: { play(subtitle: $0, triggerTime: triggerTime, offset: offset, now: now).mapError(absurd).eraseToAnyPublisher() },
                    onFailure: { Fail<[Subtitle.Line], PlayerError>(error: .decodingError($0)).eraseToAnyPublisher() }
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

extension Publisher where Output == SubtitleEvent {
    public func scanSubtitle() -> AnyPublisher<[Subtitle.Line], Failure> {
        scan([Subtitle.Line]()) { accumulator, event -> [Subtitle.Line] in
            switch event {
            case let .entry(_, line): return accumulator + [line]
            case let .exit(_, line): return accumulator.filter { $0.sequence != line.sequence }
            }
        }.eraseToAnyPublisher()
    }
}
