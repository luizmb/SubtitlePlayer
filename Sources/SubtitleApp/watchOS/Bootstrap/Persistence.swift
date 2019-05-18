import Foundation
import OpenSubtitlesDownloader
import SubtitlePlayer

public protocol Persistence {
    func saveLastLanguage(_ id: String)
    func readLastLanguage() -> String?
    func saveQuerySearches(_ searches: [String])
    func readQuerySearches() -> [String]?
    func readDownloadedSubtitles() -> [SubtitleFile]
    func saveEncoding(_ encoding: String.Encoding)
    func readEncoding() -> String.Encoding?
    func insertDownloadedSubtitle(_ substitleStorage: SubtitleFile) -> [SubtitleFile]
}

extension UserDefaults: Persistence {
    private static let lastLanguageKey = "Last-Language"
    private static let querySearchesKey = "Query-Searches"
    private static let downloadedSubtitlesKey = "Downloaded-Subtitles"
    private static let encodingKey = "Encoding"

    public func saveLastLanguage(_ id: String) {
        set(id, forKey: UserDefaults.lastLanguageKey)
    }

    public func readLastLanguage() -> String? {
        return string(forKey: UserDefaults.lastLanguageKey)
    }

    public func saveQuerySearches(_ searches: [String]) {
        set(searches, forKey: UserDefaults.querySearchesKey)
    }

    public func readQuerySearches() -> [String]? {
        return stringArray(forKey: UserDefaults.querySearchesKey)
    }

    public func readDownloadedSubtitles() -> [SubtitleFile] {
        return data(forKey: UserDefaults.downloadedSubtitlesKey)
            .flatMap { try? JSONDecoder().decode([SubtitleFile].self, from: $0) } ?? []
    }

    public func saveEncoding(_ encoding: String.Encoding) {
        set(encoding.shortName, forKey: UserDefaults.encodingKey)
    }

    public func readEncoding() -> String.Encoding? {
        return string(forKey: UserDefaults.encodingKey).flatMap(String.Encoding.init(string:))
    }

    public func insertDownloadedSubtitle(_ subtitleStorage: SubtitleFile) -> [SubtitleFile] {
        let itemsBefore = readDownloadedSubtitles()
        let itemsAfter = itemsBefore + [subtitleStorage]
        return (try? JSONEncoder().encode(itemsAfter))
            .map {
                set($0, forKey: UserDefaults.downloadedSubtitlesKey)
                return itemsAfter
            } ?? itemsBefore
    }
}
