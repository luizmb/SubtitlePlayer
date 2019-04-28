import Common
import Foundation
import RxSwift

public enum OpenSubtitlesManager { }

public typealias ReaderFull<T> = Reader<(urlSession: URLSessionProtocol, userAgent: UserAgent, fileManager: FileManagerProtocol, gzip: GzipProtocol.Type), T>
public typealias ReaderNetworking<T> = Reader<(urlSession: URLSessionProtocol, userAgent: UserAgent), T>
public typealias ReaderFileSystem<T> = Reader<(fileManager: FileManagerProtocol, gzip: GzipProtocol.Type), T>

extension OpenSubtitlesManager {
    public static func download(from sourceURL: URL) -> ReaderNetworking<Single<Data>> {
        return OpenSubtitleAPI.download(sourceURL).contramap { ($0.urlSession, $0.userAgent) }
    }

    public static func download(from sourceURL: URL, unzipInto destinationPath: String) -> ReaderFull<Single<String>> {
        return download(from: sourceURL)
            .contramap { (urlSession: $0.urlSession, userAgent: $0.userAgent) }
            .flatMap { unzipAndSave(into: destinationPath, promisedData: $0).contramap { (fileManager: $0.fileManager, gzip: $0.gzip) } }
    }

    public static func download(subtitle: SearchResponse) -> ReaderNetworking<Single<Data>> {
        return OpenSubtitleAPI.download(subtitle: subtitle).contramap { ($0.urlSession, $0.userAgent) }
    }

    public static func search(_ params: SearchParameters) -> ReaderNetworking<Single<[SearchResponse]>> {
        return OpenSubtitleAPI.search(params).contramap { ($0.urlSession, $0.userAgent) }
    }

    public static func search(_ params: SearchParameters, at index: Int) -> ReaderNetworking<Single<SearchResponse>> {
        return search(params).map { promisedResults in
            promisedResults
                .flatMap { results in
                    results
                        .subtitle(at: index)
                        .asSingle
            }
        }
    }

    public static func searchAndDownload(_ params: SearchParameters, at index: Int) -> ReaderNetworking<Single<Data>> {
        return ReaderNetworking { dependencies in
            search(params, at: index)
                .inject(dependencies)
                .flatMap { download(subtitle: $0).inject(dependencies) }
        }
    }

    public static func searchDownloadUnzip(_ params: SearchParameters, at index: Int) -> ReaderFull<Single<Data>> {
        return ReaderFull { urlSession, userAgent, fileManager, gzip in
            let networkingDependencies = (urlSession: urlSession, userAgent: userAgent)

            return search(params, at: index)
                .inject(networkingDependencies)
                    .flatMap { download(subtitle: $0).inject(networkingDependencies) }
                    .flatMap { gzip.decompress($0).asSingle }
        }
    }

    public static func searchDownloadSave(_ params: SearchParameters, at index: Int, unzipInto destinationPath: String) -> ReaderFull<Single<String>> {
        return ReaderFull { urlSession, userAgent, fileManager, gzip in
            let networkingDependencies = (urlSession: urlSession, userAgent: userAgent)

            return search(params, at: index)
                .inject(networkingDependencies)
                .flatMap { download(subtitle: $0).inject(networkingDependencies) }
                .flatMap { gzip.decompress($0).asSingle }
                .flatMap { fileManager.save($0, into: destinationPath).asSingle }
        }
    }

    public static func unzipAndSave(into path: String, promisedData: Single<Data>) -> ReaderFileSystem<Single<String>> {
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
