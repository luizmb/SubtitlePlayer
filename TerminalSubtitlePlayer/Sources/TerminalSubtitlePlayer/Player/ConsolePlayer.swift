import Combine
import Foundation
import FoundationExtensions
import SubtitleModel
import SubtitlePublisher

struct ConsolePlayer {
    static func play(path: String, encoding: String.Encoding, from sequence: Int = 0, debug: Bool = false) -> Reader<ReadFileAtPath, AnyPublisher<Void, PlayerError>> {
        let start = Date()
        return SubtitlePlayer
            .play(filePath: path, encoding: encoding, triggerTime: start, startingLine: sequence, now: start)
            .mapValue { $0.handleEvents(receiveOutput: printLine(start: start, debug: debug)).map { _ in }.eraseToAnyPublisher() }
    }

    static func play(data: Data, encoding: String.Encoding, from sequence: Int = 0, debug: Bool = false) -> AnyPublisher<Void, PlayerError> {
        let start = Date()
        return SubtitlePlayer
            .play(data: data, encoding: encoding, triggerTime: start, startingLine: sequence, now: start)
            .handleEvents(receiveOutput: printLine(start: start, debug: debug))
            .map { _ in }
            .eraseToAnyPublisher()
    }

    static func play(subtitle: Subtitle, from sequence: Int = 0, debug: Bool = false) -> AnyPublisher<Void, PlayerError> {
        let start = Date()
        return SubtitlePlayer
            .play(subtitle: subtitle, triggerTime: start, startingLine: sequence, now: start)
            .handleEvents(receiveOutput: printLine(start: start, debug: debug))
            .map { _ in }
            .eraseToAnyPublisher()
    }

    private static func printLine(start: Date, debug: Bool) -> ([Subtitle.Line]) -> Void {
        return { lines in
            if !debug {
                print("\u{001B}[2J")
            }
            guard let lastLine = lines.last else { return }
            if debug {
                print("Started:   \(start)")
                print("Offset:    \(lastLine.start)")
                print("Now:       \(Date())")
                print("Sequence:  \(lastLine.sequence)")
                print("")
            }
            print(lines.map(^\.text).joined(separator: "\n"))
            if debug {
                print("--------------------------------------------------------------------")
            }
        }
    }
}
