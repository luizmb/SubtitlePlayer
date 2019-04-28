import Common
import Foundation
import RxSwift

public enum OpenSubtitlesManager { }

extension OpenSubtitlesManager {
    public static func download(from sourceURL: URL, unzipInto destinationPath: String)
        -> Reader<(urlSession: URLSessionProtocol,
                   userAgent: UserAgent,
                   fileManager: FileManagerProtocol,
                   gzip: GzipProtocol.Type), Single<String>> {
        return download(from: sourceURL)
            .contramap { (urlSession: $0.urlSession, userAgent: $0.userAgent) }
            .flatMap { unzipAndSave(into: destinationPath, promisedData: $0).contramap { (fileManager: $0.fileManager, gzip: $0.gzip) } }
    }

    public static func download(from sourceURL: URL) -> Reader<(urlSession: URLSessionProtocol, userAgent: UserAgent), Single<Data>> {
        return OpenSubtitleAPI.download(sourceURL).contramap { ($0.urlSession, $0.userAgent) }
    }

    public static func unzipAndSave(into path: String, promisedData: Single<Data>) -> Reader<(fileManager: FileManagerProtocol, gzip: GzipProtocol.Type), Single<String>> {
        return Reader { fileManager, gzip in
            promisedData.flatMap { data in
                gzip
                    .decompress(data)
                    .flatMap { fileManager.save($0, into: path).mapError(^\.self) }
                    .asSingle
            }
        }
    }
}
