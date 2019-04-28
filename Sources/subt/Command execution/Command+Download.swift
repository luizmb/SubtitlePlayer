import Common
import Foundation
import OpenSubtitlesDownloader
import RxSwift
import SubtitlePlayer

extension Command {
    static func download(with arguments: [DownloadArgument]) -> Reader<Environment, Completable> {
        guard let source = arguments.firstNonNil(^\.subtitleURL) else { return .pure(.error(MissingArgumentError(argument: "url"))) }
        guard let destination = arguments.firstNonNil(^\.destination) else { return .pure(.error(MissingArgumentError(argument: "into"))) }
        let play = arguments.firstNonNil(^\.play) ?? false
        let encoding = arguments.firstNonNil(^\.encoding) ?? .utf8

        return OpenSubtitlesManager
            .download(from: source, unzipInto: destination)
            .contramap(^\.urlSession, ^\.openSubtitlesUserAgent, ^\.fileManager, ^\.gzip)
            .flatMap(play ? { startPlaying(promisedPath: $0, encoding: encoding) } : { .pure($0.asCompletable()) })
    }
}

private func startPlaying(promisedPath: Single<String>, encoding: String.Encoding) -> Reader<Environment, Completable> {
    return Reader { fileManager in
        promisedPath
            .flatMapCompletable { file in
                Command.play(path: file, encoding: encoding, from: 0).inject(fileManager)
            }
    }.contramap(^\.fileManager)
}
