import Foundation
import RxSwift
import SubtitlePlayer

extension Command {
    func execute() -> Completable {
        switch self {
        case let .play(arguments):
            return Command.play(with: arguments)
        }
    }

    static func play(with arguments: [PlayArgument]) -> Completable {
        guard let file = arguments.compactMap({ $0.file }).first else { return .error(MissingArgument(argument: "file")) }
        if let index = arguments.compactMap({ $0.line }).first {
            return play(from: index, path: file)
        } else {
            return playFromBeggining(path: file)
        }
    }

    static func playFromBeggining(path: String) -> Completable {
        return player(for: path)
            .asObservable()
            .flatMap {
                $0.playFromBeggining()
            }
            .do(onNext: printLine)
            .ignoreElements()
    }

    static func play(from index: Int, path: String) -> Completable {
        return player(for: path)
            .asObservable()
            .flatMap {
                $0.play(from: index)
            }
            .do(onNext: printLine)
            .ignoreElements()
    }
}

private func openFile(path: String, encoding: String.Encoding = .isoLatin1) -> Single<Subtitle> {
    guard let srt = Subtitle.from(filePath: path, encoding: encoding) else {
        print("File not found: \(path)")
        return .error(FileNotFoundError(path: path))
    }
    return .just(srt)
}

private func player(for path: String, encoding: String.Encoding = .isoLatin1) -> Single<SubtitlePlayer> {
    return openFile(path: path, encoding: encoding).map(SubtitlePlayer.init)
}

private func printLine(lines: [String]) {
    print("\u{001B}[2J")
    print(lines.joined(separator: "\n"))
}
