import Common
import Foundation
import RxSwift
import SubtitlePlayer

extension Command {
    static func play(with arguments: [PlayArgument]) -> Reader<Environment, Completable> {
        guard let file = arguments.firstNonNil(^\.file) else { return .pure(.error(MissingArgumentError(argument: "file"))) }
        let firstLine = arguments.firstNonNil(^\.line) ?? 0
        let encoding = arguments.firstNonNil(^\.encoding) ?? .utf8

        return play(path: file, encoding: encoding, from: firstLine).contramap(^\.fileManager >>> run)
    }

    static func play(path: String, encoding: String.Encoding, from sequence: Int = 0) -> Reader<FileManagerProtocol, Completable> {
        return SubtitlePlayer
            .play(filePath: path, encoding: encoding, from: sequence)
            .map { $0.do(onNext: printLine).ignoreElements() }
    }

    static func play(data: Data, encoding: String.Encoding, from sequence: Int = 0) -> Completable {
        return SubtitlePlayer
            .play(data: data, encoding: encoding, from: sequence)
            .do(onNext: printLine)
            .ignoreElements()
    }

    static func play(subtitle: Subtitle, from sequence: Int = 0) -> Completable {
        return SubtitlePlayer
            .play(subtitle: subtitle, from: sequence)
            .do(onNext: printLine)
            .ignoreElements()
    }
}

private func printLine(lines: [Subtitle.Line]) {
    print("\u{001B}[2J")
    print(lines.map(^\.text).joined(separator: "\n"))
}
