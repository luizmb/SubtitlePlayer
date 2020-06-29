import Combine
import Foundation
import FoundationExtensions
import Gzip
import SubtitleDownloader

struct World {
    let http: (URLRequest) -> Promise<(data: Data, response: URLResponse), URLError>
    let userAgent: () -> SubtitleDownloader.UserAgent
    let decoder: () -> JSONDecoder
    let fileSave: (Data, String) -> Result<String, Error>
    let fileRead: (String) -> Result<Data, Error>
    let compress: (Data) -> Result<Data, Error>
    let decompress: (Data) -> Result<Data, Error>

    var subtitleDownloaderDependencies: SubtitleDownloader.Dependencies {
        SubtitleDownloader.Dependencies(
            networking: SubtitleDownloader.Networking(
                http: http,
                userAgent: userAgent,
                decoder: decoder
            ),
            fileSave: fileSave,
            gzip: SubtitleDownloader.Gzip(compress: compress, decompress: decompress),
            decoder: decoder
        )
    }
}

extension World {
    static let `default` = World(
        http: { URLSession.shared.dataTaskPublisher(for: $0).promise },
        userAgent: { UserAgent(rawValue: "TemporaryUserAgent") },
        decoder: JSONDecoder.init,
        fileSave: { data, path in
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: path) {
                return .failure(FileManagerError.fileAlreadyExists(path: path))
            } else if fileManager.createFile(atPath: path, contents: data, attributes: nil) {
                return .success(path)
            } else {
                return .failure(FileManagerError.fileCreationHasFailed(path: path))
            }
        },
        fileRead: { path in
            FileManager
                .default
                .contents(atPath: path)
                .toResult(orError: FileManagerError.fileAlreadyExists(path: path))
        },
        compress: { data in
            data.isGzipped ? .success(data) : Result(catching: { try data.gzipped(level: .bestCompression) })
        },
        decompress: { data in
            data.isGzipped ? Result(catching: { try data.gunzipped() }) : .success(data)
        }
    )

}

enum FileManagerError: Error {
    case fileAlreadyExists(path: String)
    case fileCreationHasFailed(path: String)
    case fileReadHasFailed(path: String)
}
