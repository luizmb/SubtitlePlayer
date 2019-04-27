import Common
import Foundation
import RxSwift
import SubtitlePlayer

extension Command {
    static func play(with arguments: [PlayArgument]) -> Reader<Environment, Completable> {
        guard let file = arguments.compactMap({ $0.file }).first else { return .pure(.error(MissingArgument(argument: "file"))) }

        return arguments
            .compactMap({ $0.line })
            .first
            .fold(
                ifSome: { play(from: $0, path: file) },
                ifNone: { playFromBeggining(path: file) }
            ).contramap { $0.fileManager() }
    }

    static func playFromBeggining(path: String) -> Reader<FileManagerProtocol, Completable> {
        return player(for: path).map { subtitleStream in
            subtitleStream
                .asObservable()
                .flatMap {
                    $0.playFromBeggining()
                }
                .do(onNext: printLine)
                .ignoreElements()
        }
    }

    static func play(from index: Int, path: String) -> Reader<FileManagerProtocol, Completable> {
        return player(for: path).map { subtitleStream in
            subtitleStream
                .asObservable()
                .flatMap {
                    $0.play(from: index)
                }
                .do(onNext: printLine)
                .ignoreElements()
        }
    }
}

private func openFile(path: String, encoding: String.Encoding = .isoLatin1) -> Reader<FileManagerProtocol, Single<Subtitle>> {
    return Subtitle.from(filePath: path, encoding: encoding).map { maybeSubtitle in
        maybeSubtitle.fold(
            ifSome: Single<Subtitle>.just,
            ifNone: {
                print("File not found: \(path)")
                return Single<Subtitle>.error(FileNotFoundError(path: path))
            }
        )
    }
}

private func player(for path: String, encoding: String.Encoding = .isoLatin1) -> Reader<FileManagerProtocol, Single<SubtitlePlayer>> {
    return openFile(path: path, encoding: encoding).map { $0.map(SubtitlePlayer.init) }
}

private func printLine(lines: [String]) {
    print("\u{001B}[2J")
    print(lines.joined(separator: "\n"))
}