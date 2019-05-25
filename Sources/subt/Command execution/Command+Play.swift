import Common
import Foundation
import RxSwift
import SubtitlePlayer

extension Command {
    static func play(with arguments: [PlayArgument]) -> Reader<Environment, Completable> {
        guard let file = arguments.firstNonNil(^\.file) else { return .pure(.error(MissingArgumentError(argument: "file"))) }
        let firstLine = arguments.firstNonNil(^\.line) ?? 0
        let encoding = arguments.firstNonNil(^\.encoding) ?? .utf8
        let debug = arguments.firstNonNil(^\.debug) ?? false

        return play(path: file, encoding: encoding, from: firstLine, debug: debug).contramap(^\.fileManager)
    }

    static func play(path: String, encoding: String.Encoding, from sequence: Int = 0, debug: Bool = false) -> Reader<FileManagerProtocol, Completable> {
        let start = Date()
        return SubtitlePlayer
            .play(filePath: path, encoding: encoding, triggerTime: .now(), startingLine: sequence, now: .now())
            .map { $0.do(onNext: printLine(start: start, debug: debug)).ignoreElements() }
    }

    static func play(data: Data, encoding: String.Encoding, from sequence: Int = 0, debug: Bool = false) -> Completable {
        let start = Date()
        return SubtitlePlayer
            .play(data: data, encoding: encoding, triggerTime: .now(), startingLine: sequence, now: .now())
            .do(onNext: printLine(start: start, debug: debug))
            .ignoreElements()
    }

    static func play(subtitle: Subtitle, from sequence: Int = 0, debug: Bool = false) -> Completable {
        let start = Date()
        return SubtitlePlayer
            .play(subtitle: subtitle, triggerTime: .now(), startingLine: sequence, now: .now())
            .do(onNext: printLine(start: start, debug: debug))
            .ignoreElements()
    }
}

private func printLine(start: Date, debug: Bool) -> ([Subtitle.Line]) -> Void {
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
