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

        return OpenSubtitlesManager
            .download(from: source, unzipInto: destination)
            .contramap { (urlSession: $0.urlSession(), userAgent: $0.openSubtitlesUserAgent(), fileManager: $0.fileManager(), gzip: $0.gzip()) }
            .flatMap(play ? startPlaying : { .pure($0.asCompletable()) })
    }
}

private func startPlaying(promisedPath: Single<String>) -> Reader<Environment, Completable> {
    return Reader { fileManager in
        promisedPath
            .flatMapCompletable { file in
                Command.play(path: file, from: 0).inject(fileManager)
            }
    }.contramap(^\.fileManager >>> run)
}
