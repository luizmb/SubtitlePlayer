import Foundation
import AppModuleDownload
import AppModuleSettings

extension AppAction {
    var scene: SceneAction? {
        get {
            guard case let .scene(value) = self else { return nil }
            return value
        }
        set {
            guard case .scene = self, let newValue = newValue else { return }
            self = .scene(newValue)
        }
    }

    var isScene: Bool {
        self.scene != nil
    }
}

extension AppAction {
    var download: DownloadModule.Action? {
        get {
            guard case let .download(value) = self else { return nil }
            return value
        }
        set {
            guard case .download = self, let newValue = newValue else { return }
            self = .download(newValue)
        }
    }

    var isDownload: Bool {
        self.download != nil
    }
}

extension AppAction {
    var settings: SettingsModule.Action? {
        get {
            guard case let .settings(value) = self else { return nil }
            return value
        }
        set {
            guard case .settings = self, let newValue = newValue else { return }
            self = .settings(newValue)
        }
    }

    var isSettings: Bool {
        self.settings != nil
    }
}

extension SceneAction {
    public var active: UUID? {
        get {
            guard case let .active(value) = self else { return nil }
            return value
        }
        set {
            guard case .active = self, let newValue = newValue else { return }
            self = .active(id: newValue)
        }
    }

    public var isActive: Bool {
        self.active != nil
    }
}

extension SceneAction {
    public var inactive: UUID? {
        get {
            guard case let .inactive(value) = self else { return nil }
            return value
        }
        set {
            guard case .inactive = self, let newValue = newValue else { return }
            self = .inactive(id: newValue)
        }
    }

    public var isInactive: Bool {
        self.inactive != nil
    }
}

extension SceneAction {
    public var background: UUID? {
        get {
            guard case let .background(value) = self else { return nil }
            return value
        }
        set {
            guard case .background = self, let newValue = newValue else { return }
            self = .background(id: newValue)
        }
    }

    public var isBackground: Bool {
        self.background != nil
    }
}

extension AppState {
    var download: DownloadModule.State {
        get {
            .init(
                currentQueryFilter: currentQueryFilter,
                currentSeasonFilter: currentSeasonFilter,
                currentEpisodeFilter: currentEpisodeFilter,
                languages: languages,
                currentLanguageFilter: currentLanguageFilter,
                favouriteLanguage: favouriteLanguage,
                lastSearchResults: lastSearchResults,
                downloadingSubtitles: downloadingSubtitles,
                downloadFailures: downloadFailures,
                downloadedSubtitles: downloadedSubtitles,
                currentErrorPopup: currentErrorPopup,
                queryHistory: queryHistory,
                showingQueryHistory: showingQueryHistory,
                isSearching: isSearching
            )
        }
        set {
            currentQueryFilter = newValue.currentQueryFilter
            currentSeasonFilter = newValue.currentSeasonFilter
            currentEpisodeFilter = newValue.currentEpisodeFilter
            languages = newValue.languages
            currentLanguageFilter = newValue.currentLanguageFilter
            favouriteLanguage = newValue.favouriteLanguage
            lastSearchResults = newValue.lastSearchResults
            downloadingSubtitles = newValue.downloadingSubtitles
            downloadFailures = newValue.downloadFailures
            downloadedSubtitles = newValue.downloadedSubtitles
            currentErrorPopup = newValue.currentErrorPopup
            queryHistory = newValue.queryHistory
            showingQueryHistory = newValue.showingQueryHistory
            isSearching = newValue.isSearching
        }
    }

    var settings: SettingsModule.State {
        get {
            .init(
                encodings: encodings,
                selectedEncoding: selectedEncoding,
                languages: languages,
                favouriteLanguage: favouriteLanguage
            )
        }
        set {
            encodings = newValue.encodings
            selectedEncoding = newValue.selectedEncoding
            languages = newValue.languages
            favouriteLanguage = newValue.favouriteLanguage
        }
    }
}
