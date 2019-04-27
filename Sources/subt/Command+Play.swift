import Common
import Foundation
import RxSwift
import SubtitlePlayer

extension Command {
    static func play(with arguments: [PlayArgument]) -> Reader<Environment, Completable> {
        return Reader { fileManager in
            guard let file = arguments.compactMap({ $0.file }).first else { return .error(MissingArgument(argument: "file")) }
            if let index = arguments.compactMap({ $0.line }).first {
                return play(from: index, path: file).inject(fileManager.fileManager())
            } else {
                return playFromBeggining(path: file).inject(fileManager.fileManager())
            }
        }
    }

    static func playFromBeggining(path: String) -> Reader<FileManagerProtocol, Completable> {
        return Reader { fileManager in
            return player(for: path)
                .inject(fileManager)
                .asObservable()
                .flatMap {
                    $0.playFromBeggining()
                }
                .do(onNext: printLine)
                .ignoreElements()
        }
    }

    static func play(from index: Int, path: String) -> Reader<FileManagerProtocol, Completable> {
        return Reader { fileManager in
            return player(for: path)
                .inject(fileManager)
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
    return Reader { fileManager in
        guard let srt = Subtitle.from(filePath: path, encoding: encoding).inject(fileManager) else {
            print("File not found: \(path)")
            return .error(FileNotFoundError(path: path))
        }
        return .just(srt)
    }
}

private func player(for path: String, encoding: String.Encoding = .isoLatin1) -> Reader<FileManagerProtocol, Single<SubtitlePlayer>> {
    return openFile(path: path, encoding: encoding).map { $0.map(SubtitlePlayer.init) }
}

private func printLine(lines: [String]) {
    print("\u{001B}[2J")
    print(lines.joined(separator: "\n"))
}
