import Foundation
import OpenSubtitlesDownloader

public protocol Persistence {
    func saveLastLanguage(_ id: String)
    func readLastLanguage() -> String?
    func saveQuerySearches(_ searches: [String])
    func readQuerySearches() -> [String]?
    func readDownloadedSubtitles() -> [(id: String, url: String, file: String)]
    func insertDownloadedSubtitle(id: String, url: String, file: String)
}

extension UserDefaults: Persistence {
    private static let lastLanguageKey = "Last-Language"
    private static let querySearchesKey = "Query-Searches"
    private static let downloadedSubtitlesKey = "Downloaded-Subtitles"

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

    public func readDownloadedSubtitles() -> [(id: String, url: String, file: String)] {
        return data(forKey: UserDefaults.downloadedSubtitlesKey)
            .flatMap { try? PropertyListSerialization.propertyList(from: $0, options: .init(), format: nil) }
            .flatMap { $0 as? [(id: String, url: String, file: String)] } ?? []
    }

    public func insertDownloadedSubtitle(id: String, url: String, file: String) {
        let items = readDownloadedSubtitles() + [(id: id, url: url, file: file)]
        (
            try? PropertyListSerialization.data(fromPropertyList: items,
                                                format: PropertyListSerialization.PropertyListFormat.xml, options: .init())
        ).map {
            set($0, forKey: UserDefaults.downloadedSubtitlesKey)
        }
    }
}
