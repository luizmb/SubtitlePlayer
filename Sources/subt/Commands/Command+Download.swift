import Common
import Foundation
import OpenSubtitlesDownloader
import RxSwift
import SubtitlePlayer

extension Command {
    static func download(with arguments: [DownloadArgument]) -> Reader<Environment, Completable> {
        guard let source = arguments.firstNonNil(^\.subtitleURL) else { return .pure(.error(MissingArgument(argument: "url"))) }
        guard let destination = arguments.firstNonNil(^\.destination) else { return .pure(.error(MissingArgument(argument: "into"))) }
        let play = arguments.firstNonNil(^\.play) ?? false

        return downloadFile(from: source)
            .flatMap(partialApply(unzipAndSave, destination))
            .flatMap(play ? startPlaying : { .pure($0.asCompletable()) })
    }
}

private func downloadFile(from: URL) -> Reader<Environment, Single<Data>> {
    return OpenSubtitleAPI
        .download(from)
        .contramap { ($0.urlSession(), $0.openSubtitlesUserAgent()) }
}

private func unzipAndSave(into path: String, promisedData: Single<Data>) -> Reader<Environment, Single<String>> {
    return Reader { (fileManager, gzip) in
        promisedData.flatMap { data in
            gzip
                .decompress(data)
                .flatMap { fileManager.save($0, into: path).mapError(^\.self) }
                .asSingle
        }
    }.contramap { ($0.fileManager(), $0.gzip()) }
}

private func startPlaying(promisedPath: Single<String>) -> Reader<Environment, Completable> {
    return Reader { fileManager in
        promisedPath
            .flatMapCompletable { file in
                Command.playFromBeggining(path: file).inject(fileManager)
            }
    }.contramap(^\.fileManager >>> run)
}
