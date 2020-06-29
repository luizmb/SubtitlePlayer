import Combine
import Foundation
import FoundationExtensions

public enum OpenSubtitlesManager { }

private let networking: (Dependencies) -> Networking = ^(\.networking.http, \.networking.userAgent, \.decoder)
private let fileSystem: (Dependencies) -> FileSystem = ^(\.fileSave, \.gzip)

extension OpenSubtitlesManager {
    public static func download(from sourceURL: URL) -> Reader<Networking, Promise<Data, NetworkError>> {
        OpenSubtitlesAPI.download(sourceURL)
    }

    public static func download(from sourceURL: URL, unzipInto destinationPath: String) -> Reader<Dependencies, Promise<String, OpenSubtitlesError>> {
        download(from: sourceURL)
            .contramapEnvironment(networking)
            .mapPublisherError(OpenSubtitlesError.networkError)
            .flatMapPublisher { data in
                unzipAndSave(into: destinationPath, data: data)
                    .mapValue { $0.mapError(OpenSubtitlesError.fileSystemError).promise }
                    .contramapEnvironment(fileSystem)
            }
            .mapValue { $0.promise }
    }

    public static func download(subtitle: SearchResponse) -> Reader<Networking, Promise<Data, NetworkError>> {
        OpenSubtitlesAPI.download(subtitle: subtitle)
    }

    public static func search(_ params: SearchParameters) -> Reader<Networking, Promise<[SearchResponse], NetworkError>> {
        OpenSubtitlesAPI.search(params)
    }

    public static func search(_ params: SearchParameters, at index: Int) -> Reader<Networking, Promise<SearchResponse, OpenSubtitlesError>> {
        search(params)
            .mapPublisherError(OpenSubtitlesError.networkError)
            .flatMapPublisher { searchResponses in
                searchResponses
                    .subtitle(at: index)
                    .mapError(OpenSubtitlesError.indexOutOfBounds)
                    .promise
            }
            .mapValue { $0.promise }
    }

    public static func searchAndDownload(_ params: SearchParameters, at index: Int) -> Reader<Networking, Promise<Data, OpenSubtitlesError>> {
        search(params, at: index)
            .flatMapPublisher { (searchResponse: SearchResponse) -> Reader<Networking, Promise<Data, OpenSubtitlesError>> in
                download(subtitle: searchResponse)
                    .mapPublisherError(OpenSubtitlesError.networkError)
                    .mapValue { $0.promise }
            }
            .mapValue { $0.promise }
    }

    public static func searchDownloadUnzip(_ params: SearchParameters, at index: Int) -> Reader<Dependencies, Promise<Data, OpenSubtitlesError>> {
        search(params, at: index)
            .flatMapPublisher { download(subtitle: $0).mapPublisherError(OpenSubtitlesError.networkError) }
            .contramapEnvironment(networking)
            .flatMapPublisher { data in
                decompress(data: data)
                    .mapResultError(OpenSubtitlesError.fileSystemError)
                    .mapValue { $0.promise }
                    .contramapEnvironment(\Dependencies.gzip)
            }
            .mapValue { $0.promise }
    }

    public static func searchDownloadSave(_ params: SearchParameters, at index: Int, unzipInto destinationPath: String) -> Reader<Dependencies, Promise<String, OpenSubtitlesError>> {
        search(params, at: index)
            .flatMapPublisher { download(subtitle: $0).mapPublisherError(OpenSubtitlesError.networkError) }
            .contramapEnvironment(networking)
            .flatMapPublisher { data in
                unzipAndSave(into: destinationPath, data: data)
                    .mapResultError(OpenSubtitlesError.fileSystemError)
                    .mapValue { $0.promise }
                    .contramapEnvironment(fileSystem)
            }
            .mapValue { $0.promise }
    }

    public static func unzipAndSave(into path: String, data: Data) -> Reader<FileSystem, Result<String, FileSystemError>> {
        decompress(data: data)
            .contramapEnvironment(\FileSystem.gzip)
            .flatMapResult {
                save(data: $0, into: path)
            }
    }

    private static func decompress(data: Data) -> Reader<Gzip, Result<Data, FileSystemError>> {
        Reader { dependencies in
            dependencies
                .decompress(data)
                .mapError(FileSystemError.decompressError)
        }
    }

    private static func save(data: Data, into path: String) -> Reader<FileSystem, Result<String, FileSystemError>> {
        Reader { dependencies in
            dependencies
                .fileSave(data, path)
                .mapError { FileSystemError.cannotSave(path: path, error: $0) }
        }
    }
}

public enum OpenSubtitlesError: Error, Equatable {
    case networkError(NetworkError)
    case fileSystemError(FileSystemError)
    case indexOutOfBounds(ResultIndexOutOfBoundsError)
}

public enum FileSystemError: Error, Equatable {
    case cannotSave(path: String, error: Error)
    case decompressError(Error)
    case compressError(Error)
}

extension FileSystemError {
    public static func == (lhs: FileSystemError, rhs: FileSystemError) -> Bool {
        switch (lhs, rhs) {
        case let (.cannotSave(lhsPath, lhsError), .cannotSave(rhsPath, rhsError)):
            return lhsPath == rhsPath && lhsError.localizedDescription == rhsError.localizedDescription
        case let (.decompressError(lhsError), .decompressError(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case let (.compressError(lhsError), .compressError(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}
