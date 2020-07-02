import Combine
import CombineRex
import Foundation
import SubtitleModel
import SubtitleDownloader
import SwiftRex

public enum DownloadModule {
    public enum Action {
        case loadModule
        case setQueryValue(String)
        case setSeasonValue(String)
        case setEpisodeValue(String)
        case selectLanguage(LanguageId)
        case selectFavouriteLanguage
        case search
        case showQueryHistory
        case searchHasStarted
        case gotSearchResults([SearchResponse])
        case gotSearchError(NetworkError)
        case selectSearchResultItem(id: String)
        case showItemOnLibrary(id: String)
        case downloadHasBeenCancelled(id: String)
        case downloadHasFailed(id: String, error: OpenSubtitlesError)
        case downloadHasStarted(item: SearchResponse)
        case downloadHasCompleted(id: String)
        case showErrorPopup(id: String, error: OpenSubtitlesError)
        case dismissErrorPopup
        case retry(id: String)
        case removeHistoryEntry(IndexSet)
        case cleanHistory
        case dismissHistory
        case showHistory
        case gotSearchHistory([String])
    }

    public struct State: Equatable {
        public var currentQueryFilter: String?
        public var currentSeasonFilter: String?
        public var currentEpisodeFilter: String?
        public var languages: [LanguageId]
        public var currentLanguageFilter: LanguageId
        public var favouriteLanguage: LanguageId
        public var lastSearchResults: Result<[SearchResponse], NetworkError>
        public var downloadingSubtitles: [SearchResponse]
        public var downloadFailures: [DownloadFailure]
        public var downloadedSubtitles: [String]
        public var currentErrorPopup: DownloadFailure?
        public var queryHistory: [String]
        public var showingQueryHistory: Bool
        public var isSearching: Bool

        public init(
            currentQueryFilter: String?,
            currentSeasonFilter: String?,
            currentEpisodeFilter: String?,
            languages: [LanguageId],
            currentLanguageFilter: LanguageId,
            favouriteLanguage: LanguageId,
            lastSearchResults: Result<[SearchResponse], NetworkError>,
            downloadingSubtitles: [SearchResponse],
            downloadFailures: [DownloadFailure],
            downloadedSubtitles: [String],
            currentErrorPopup: DownloadFailure?,
            queryHistory: [String],
            showingQueryHistory: Bool,
            isSearching: Bool
        ) {
            self.currentQueryFilter = currentQueryFilter
            self.currentSeasonFilter = currentSeasonFilter
            self.currentEpisodeFilter = currentEpisodeFilter
            self.languages = languages
            self.currentLanguageFilter = currentLanguageFilter
            self.favouriteLanguage = favouriteLanguage
            self.lastSearchResults = lastSearchResults
            self.downloadingSubtitles = downloadingSubtitles
            self.downloadFailures = downloadFailures
            self.downloadedSubtitles = downloadedSubtitles
            self.currentErrorPopup = currentErrorPopup
            self.queryHistory = queryHistory
            self.showingQueryHistory = showingQueryHistory
            self.isSearching = isSearching
        }
    }

    public struct DownloadFailure: Equatable {
        public let id: String
        public let error: OpenSubtitlesError

        public init(id: String, error: OpenSubtitlesError) {
            self.id = id
            self.error = error
        }
    }

    public struct Dependencies {
        public let searchSubtitles: (SearchParameters) -> Promise<[SearchResponse], NetworkError>
        public let downloadFile: (SearchResponse) -> Promise<SubtitleFile, OpenSubtitlesError>
        public let deleteSearchHistory: () -> Void
        public let saveSearchHistory: ([String]) -> Void
        public let listSearchHistory: () -> [String]

        public init(
            searchSubtitles: @escaping (SearchParameters) -> Promise<[SearchResponse], NetworkError>,
            downloadFile: @escaping (SearchResponse) -> Promise<SubtitleFile, OpenSubtitlesError>,
            deleteSearchHistory: @escaping () -> Void,
            saveSearchHistory: @escaping ([String]) -> Void,
            listSearchHistory: @escaping () -> [String]
        ) {
            self.searchSubtitles = searchSubtitles
            self.downloadFile = downloadFile
            self.deleteSearchHistory = deleteSearchHistory
            self.saveSearchHistory = saveSearchHistory
            self.listSearchHistory = listSearchHistory
        }
    }

    public static let reducer = Reducer<Action, State> { action, state in
        var state = state
        switch action {
        case let .setQueryValue(newQuery):
            state.currentQueryFilter = newQuery.isEmpty ? nil : newQuery
        case let .setSeasonValue(newSeason):
            state.currentSeasonFilter = newSeason.isEmpty ? nil : newSeason
        case let .setEpisodeValue(newEpisode):
            state.currentEpisodeFilter = newEpisode.isEmpty ? nil : newEpisode
        case let .selectLanguage(newLanguage):
            state.currentLanguageFilter = newLanguage
        case .selectFavouriteLanguage:
            state.currentLanguageFilter = state.favouriteLanguage
        case let .gotSearchError(error):
            state.isSearching = false
            state.lastSearchResults = .failure(error)
        case let .gotSearchResults(searchResult):
            state.isSearching = false
            state.lastSearchResults = .success(searchResult)
        case let .showItemOnLibrary(id):
            // TODO: navigation
            break
        case .showQueryHistory:
            // TODO: navigation
            break
        case .selectSearchResultItem:
            // TODO: navigation
            break
        case .search:
            if let queryFilter = state.currentQueryFilter?.trimmingCharacters(in: .whitespacesAndNewlines) {
                state.queryHistory.removeAll(where: { $0.trimmingCharacters(in: .whitespacesAndNewlines) == queryFilter })
                state.queryHistory.append(queryFilter)
            }
        case let .downloadHasBeenCancelled(id):
            state.downloadingSubtitles.removeAll(where: { $0.idSubtitleFile == id })
            state.downloadFailures.removeAll(where: { $0.id == id })
            state.downloadedSubtitles.removeAll(where: { $0 == id })
        case let .downloadHasStarted(item):
            state.downloadingSubtitles.append(item)
            state.downloadFailures.removeAll(where: { $0.id == item.idSubtitleFile })
            state.downloadedSubtitles.removeAll(where: { $0 == item.idSubtitleFile })
        case let .downloadHasFailed(id, error):
            state.downloadFailures.append(DownloadFailure(id: id, error: error))
            state.downloadingSubtitles.removeAll(where: { $0.idSubtitleFile == id })
            state.downloadedSubtitles.removeAll(where: { $0 == id })
        case let .downloadHasCompleted(id):
            state.downloadFailures.removeAll(where: { $0.id == id })
            state.downloadingSubtitles.removeAll(where: { $0.idSubtitleFile == id })
            state.downloadedSubtitles.append(id)
        case let .showErrorPopup(id, error):
            state.currentErrorPopup = DownloadFailure(id: id, error: error)
        case let .retry(id):
            state.downloadingSubtitles.removeAll(where: { $0.idSubtitleFile == id })
            state.downloadFailures.removeAll(where: { $0.id == id })
            state.downloadedSubtitles.removeAll(where: { $0 == id })
            state.currentErrorPopup = nil
        case .dismissErrorPopup:
            state.currentErrorPopup = nil
        case .cleanHistory:
            state.queryHistory = []
        case let .removeHistoryEntry(indexSet):
            indexSet.forEach {
                state.queryHistory.removeSafe(at: $0)
            }
        case .dismissHistory:
            state.showingQueryHistory = false
        case .showHistory:
            state.showingQueryHistory = true
        case .searchHasStarted:
            state.isSearching = true
        case let .gotSearchHistory(searchHistory):
            state.queryHistory = searchHistory
        case .loadModule:
            return state
        }
        return state
    }

    public static let middleware = EffectMiddleware<Action, Action, State, Dependencies>.onAction { action, state, context in
        switch action {
        case .loadModule:
            return Effect.just(.gotSearchHistory(context.dependencies.listSearchHistory()))

        case .search:
            return context.dependencies.searchSubtitles(
                SearchParameters(
                    imdb: nil,
                    movieInfo: nil,
                    query: state.currentQueryFilter,
                    episode: state.currentEpisodeFilter.flatMap(Int.init),
                    season: state.currentSeasonFilter.flatMap(Int.init),
                    language: state.currentLanguageFilter,
                    tag: nil
                )
            )
            .map { EffectOutput<Action>.dispatch(.gotSearchResults($0)) }
            .catch { Just(EffectOutput.dispatch(.gotSearchError($0))) }
            .prepend(EffectOutput.dispatch(.searchHasStarted))
            .handleEvents(receiveSubscription: { _ in context.dependencies.saveSearchHistory(state.queryHistory) })
            .asEffect

        case let .retry(id):
            return .just(.selectSearchResultItem(id: id))

        case let .selectSearchResultItem(id):
            return selectSearchResultItem(id: id, state: state, context: context)

        case .cleanHistory:
            return .fireAndForget { context.dependencies.deleteSearchHistory() }

        case .removeHistoryEntry:
            return .fireAndForget { context.dependencies.saveSearchHistory(state.queryHistory) }

        case .setQueryValue, .setSeasonValue, .setEpisodeValue, .selectLanguage, .showQueryHistory, .gotSearchError, .gotSearchResults,
             .showItemOnLibrary, .downloadHasBeenCancelled, .downloadHasStarted, .downloadHasFailed, .downloadHasCompleted, .showErrorPopup,
             .dismissErrorPopup, .dismissHistory, .showHistory, .searchHasStarted, .gotSearchHistory, .selectFavouriteLanguage:
            return .doNothing
        }
    }

    private static func selectSearchResultItem(id: String, state: State, context: EffectMiddleware<Action, Action, State, Dependencies>.Context) -> Effect<Action> {
        if state.downloadedSubtitles.contains(id) {
            return .just(.showItemOnLibrary(id: id))
        }

        if state.downloadingSubtitles.contains(where: { $0.idSubtitleFile == id }) {
            context.toCancel(id)
            return .just(.downloadHasBeenCancelled(id: id))
        }

        if let downloadFailure = state.downloadFailures.first(where: { $0.id == id }) {
            return .just(.showErrorPopup(id: id, error: downloadFailure.error))
        }

        guard case let .success(items) = state.lastSearchResults,
              let item = items.first(where: { $0.idSubtitleFile == id })
        else { return .doNothing }

        return context
            .dependencies
            .downloadFile(item)
            .map { EffectOutput<Action>.dispatch(.downloadHasCompleted(id: $0.id)) }
            .catch { Just(.dispatch(.downloadHasFailed(id: id, error: $0))) }
            .prepend(.dispatch(.downloadHasStarted(item: item)))
            .asEffect
    }
}
