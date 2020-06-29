import Combine
import Foundation
import Gzip
import SubtitleDownloader
import SwiftRex

typealias Promise = Publishers.Promise

struct World {
    let store: () -> AnyStoreType<AppAction, AppState>
    let http: (URLRequest) -> Promise<(data: Data, response: URLResponse), URLError>
    let userAgent: () -> SubtitleDownloader.UserAgent
    let decoder: () -> JSONDecoder
    let fileSave: (Data, String) -> Result<String, Error>
    let fileRead: (String) -> Result<Data, Error>
    let compress: (Data) -> Result<Data, Error>
    let decompress: (Data) -> Result<Data, Error>
    let repository: () -> UserDefaults
}

extension World {
    private static var _store: AnyStoreType<AppAction, AppState> {
        ReduxStoreBase<AppAction, AppState>(
            subject: .combine(initialValue: .empty),
            reducer: AppModule.reducer,
            middleware: AppModule.middleware.inject(.default)
        ).eraseToAnyStoreType()
    }

    static let `default` = World(
        store: { _store },
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
        },
        repository: { .standard }
    )
}

extension UserDefaults {
    private static let selectedEncoding = "selectedEncoding"
    private static let favouriteLanguage = "favouriteLanguage"
    private static let searchHistory = "searchHistory"

    fileprivate func saveSelectedEncoding(_ encoding: String.Encoding) {
        setValue(encoding.rawValue, forKey: Self.selectedEncoding)
    }

    fileprivate func getSelectedEncoding() -> String.Encoding {
        String.Encoding(rawValue: UInt(integer(forKey: Self.selectedEncoding)))
    }

    fileprivate func saveFavouriteLanguage(_ language: LanguageId) {
        setValue(language.rawValue, forKey: Self.favouriteLanguage)
    }

    fileprivate func getFavouriteLanguage() -> LanguageId {
        string(forKey: Self.favouriteLanguage)
            .flatMap(LanguageId.init(rawValue:))
            ?? .all
    }

    fileprivate func deleteSearchHistory() {
        removeObject(forKey: Self.searchHistory)
    }

    fileprivate func saveSearchHistory(_ records: [String]) {
        setValue(records, forKey: Self.searchHistory)
    }

    fileprivate func listSearchHistory() -> [String] {
        stringArray(forKey: Self.searchHistory) ?? []
    }
}

extension World {
    private var subtitleDownloaderDependencies: SubtitleDownloader.Dependencies {
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
    var saveSelectedEncoding: (String.Encoding) -> Void { repository().saveSelectedEncoding }
    var getSelectedEncoding: () -> String.Encoding { repository().getSelectedEncoding }
    var saveFavouriteLanguage: (LanguageId) -> Void { repository().saveFavouriteLanguage }
    var getFavouriteLanguage: () -> LanguageId { repository().getFavouriteLanguage }
    var deleteSearchHistory: () -> Void { repository().deleteSearchHistory }
    var saveSearchHistory: ([String]) -> Void { repository().saveSearchHistory }
    var listSearchHistory: () -> [String] { repository().listSearchHistory }
    var searchSubtitles: (SearchParameters) -> Promise<[SearchResponse], NetworkError> {
        { OpenSubtitlesManager.search($0).inject(subtitleDownloaderDependencies.networking) }
    }
    var downloadFile: (SearchResponse) -> Promise<SubtitleFile, OpenSubtitlesError> {
        { searchResponse in
            OpenSubtitlesManager
                .download(from: searchResponse.subDownloadLink, unzipInto: "path")
                .mapPublisher { _ in SubtitleFile.from(searchResponse: searchResponse) }
                .mapValue { $0.promise }
                .inject(subtitleDownloaderDependencies)
        }
    }
}

enum FileManagerError: Error {
    case fileAlreadyExists(path: String)
    case fileCreationHasFailed(path: String)
    case fileReadHasFailed(path: String)
}
