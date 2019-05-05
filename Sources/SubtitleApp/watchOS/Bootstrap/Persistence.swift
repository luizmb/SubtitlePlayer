import Foundation

public protocol Persistence {
    func saveLastLanguage(_ id: String)
    func readLastLanguage() -> String?
    func saveQuerySearches(_ searches: [String])
    func readQuerySearches() -> [String]?
}

extension UserDefaults: Persistence {
    private static let lastLanguageKey = "Last-Language"
    private static let querySearchesKey = "Query-Searches"

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
}
