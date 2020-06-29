import AppModuleDownload
import AppModuleSettings
import CombineRex
import FoundationExtensions
import LoggerMiddleware
import SubtitleDownloader
import SwiftRex
import SwiftUI

struct AppState: Equatable {
    var isLoaded: Bool
    var currentQueryFilter: String?
    var currentSeasonFilter: String?
    var currentEpisodeFilter: String?
    var languages: [LanguageId]
    var currentLanguageFilter: LanguageId
    var lastSearchResults: Result<[SearchResponse], NetworkError>
    var downloadingSubtitles: [SearchResponse]
    var downloadFailures: [DownloadModule.DownloadFailure]
    var downloadedSubtitles: [String]
    var currentErrorPopup: DownloadModule.DownloadFailure?
    var queryHistory: [String]
    var showingQueryHistory: Bool
    var isSearching: Bool
    var encodings: [String.Encoding]
    var selectedEncoding: String.Encoding
    var favouriteLanguage: LanguageId

    static var empty: AppState {
        .init(
            isLoaded: false,
            languages: [],
            currentLanguageFilter: .all,
            lastSearchResults: .success([]),
            downloadingSubtitles: [],
            downloadFailures: [],
            downloadedSubtitles: [],
            queryHistory: [],
            showingQueryHistory: false,
            isSearching: false,
            encodings: [],
            selectedEncoding: .utf8,
            favouriteLanguage: .all
        )
    }
}

enum AppAction {
    case scene(SceneAction)
    case download(DownloadModule.Action)
    case settings(SettingsModule.Action)
}

enum SceneAction {
    case appIsLoaded
    case active(id: UUID)
    case inactive(id: UUID)
    case background(id: UUID)
}

let sceneReducer = Reducer<SceneAction, Bool> { action, isLoaded in
    switch action {
    case .appIsLoaded: return true
    case .active, .inactive, .background: return isLoaded
    }
}

let sceneMiddleware = EffectMiddleware<SceneAction, AppAction, Bool, Void>.onAction { action, isLoaded, context in
    switch action {
    case .active:
        if isLoaded { return .doNothing }
        return Effect.sequence(
            .scene(.appIsLoaded),
            .settings(.loadModule),
            .download(.loadModule)
        )
    case .inactive, .background, .appIsLoaded:
        return .doNothing
    }
}

enum AppModule {
    static let middleware: MiddlewareReader<World, ComposedMiddleware<AppAction, AppAction, AppState>> = [
        .pure(
            LoggerMiddleware()
                .lift(outputActionMap: absurd)
                .eraseToAnyMiddleware()
        ),

        .pure(
            sceneMiddleware
            .lift(
                inputActionMap: \AppAction.scene,
                stateMap: \AppState.isLoaded
            ).eraseToAnyMiddleware()
        ),

        SettingsModule.middleware
        .lift(
            inputAction: \AppAction.settings,
            outputAction: AppAction.settings,
            state: \AppState.settings,
            dependencies: { (world: World) in
                SettingsModule.Dependencies(
                    saveSelectedEncoding: world.saveSelectedEncoding,
                    getSelectedEncoding: world.getSelectedEncoding,
                    saveFavouriteLanguage: world.saveFavouriteLanguage,
                    getFavouriteLanguage: world.getFavouriteLanguage,
                    deleteSearchHistory: world.deleteSearchHistory
                )
            }
        ).mapMiddleware { $0.eraseToAnyMiddleware() },

        DownloadModule.middleware
        .lift(
            inputAction: \AppAction.download,
            outputAction: AppAction.download,
            state: \AppState.download,
            dependencies: { (world: World) in
                DownloadModule.Dependencies(
                    searchSubtitles: world.searchSubtitles,
                    downloadFile: world.downloadFile,
                    deleteSearchHistory: world.deleteSearchHistory,
                    saveSearchHistory: world.saveSearchHistory,
                    listSearchHistory: world.listSearchHistory
                )
            }
        ).mapMiddleware { $0.eraseToAnyMiddleware() }
    ].reduce(MiddlewareReader.pure(ComposedMiddleware()), <>)

    static let reducer: Reducer<AppAction, AppState> = [
        sceneReducer
        .lift(action: \AppAction.scene, state: \AppState.isLoaded   ),

        SettingsModule.reducer
        .lift(action: \AppAction.settings, state: \AppState.settings),

        DownloadModule.reducer
        .lift(action: \AppAction.download, state: \AppState.download)
    ].reduce(.identity, <>)
}
