import Common
import Foundation
import RxSwift
import SubtitlePlayer

extension Command {
    static func play(with arguments: [PlayArgument]) -> Reader<Environment, Completable> {
        guard let file = arguments.firstNonNil(^\.file) else { return .pure(.error(MissingArgument(argument: "file"))) }
        let firstLine = arguments.firstNonNil(^\.line) ?? 0

        return play(path: file, from: firstLine).contramap(^\.fileManager >>> run)
    }

    static func play(path: String, from sequence: Int = 0) -> Reader<FileManagerProtocol, Completable> {
        return player(for: path).map { subtitleStream in
            subtitleStream
                .asObservable()
                .flatMap { $0.play(from: sequence) }
                .do(onNext: printLine)
                .ignoreElements()
        }
    }

    static func play(subtitle: Subtitle, from sequence: Int = 0) -> Completable {
        return SubtitlePlayer(subtitle: subtitle)
            .play(from: sequence)
            .do(onNext: printLine)
            .ignoreElements()
    }
}

private func openFile(path: String, encoding: String.Encoding = .isoLatin1) -> Reader<FileManagerProtocol, Single<Subtitle>> {
    return Subtitle.from(filePath: path, encoding: encoding).map { result in
        result.fold(
            ifSuccess: Single<Subtitle>.just,
            ifFailure: {
                print("File not found: \(path)")
                return Single<Subtitle>.error($0)
            }
        )
    }
}

private func player(for path: String, encoding: String.Encoding = .isoLatin1) -> Reader<FileManagerProtocol, Single<SubtitlePlayer>> {
    return openFile(path: path, encoding: encoding).map { $0.map(SubtitlePlayer.init) }
}

private func printLine(lines: [Subtitle.Line]) {
    print("\u{001B}[2J")
    print(lines.map(^\.text).joined(separator: "\n"))
}
