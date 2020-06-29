import Combine
import CombineRex
import Foundation
import SubtitleModel
import SubtitleDownloader
import SwiftRex

public enum SettingsModule {
    public enum Action {
        case loadModule
        case selectEncoding(String.Encoding)
        case selectFavouriteLanguage(LanguageId)
        case deleteSearchHistory
        case gotAllEncodings([String.Encoding])
        case gotAllLanguages([LanguageId])
    }

    public struct State: Equatable {
        public var encodings: [String.Encoding]
        public var selectedEncoding: String.Encoding
        public var languages: [LanguageId]
        public var favouriteLanguage: LanguageId

        public init(
            encodings: [String.Encoding],
            selectedEncoding: String.Encoding,
            languages: [LanguageId],
            favouriteLanguage: LanguageId
        ) {
            self.encodings = encodings
            self.selectedEncoding = selectedEncoding
            self.languages = languages
            self.favouriteLanguage = favouriteLanguage
        }

        public static var empty: State {
            .init(
                encodings: [],
                selectedEncoding: .utf8,
                languages: [],
                favouriteLanguage: .all
            )
        }
    }

    public struct Dependencies {
        public let saveSelectedEncoding: (String.Encoding) -> Void
        public let getSelectedEncoding: () -> String.Encoding
        public let saveFavouriteLanguage: (LanguageId) -> Void
        public let getFavouriteLanguage: () -> LanguageId
        public let deleteSearchHistory: () -> Void

        public init(
            saveSelectedEncoding: @escaping (String.Encoding) -> Void,
            getSelectedEncoding: @escaping () -> String.Encoding,
            saveFavouriteLanguage: @escaping (LanguageId) -> Void,
            getFavouriteLanguage: @escaping () -> LanguageId,
            deleteSearchHistory: @escaping () -> Void
        ) {
            self.saveSelectedEncoding = saveSelectedEncoding
            self.getSelectedEncoding = getSelectedEncoding
            self.saveFavouriteLanguage = saveFavouriteLanguage
            self.getFavouriteLanguage = getFavouriteLanguage
            self.deleteSearchHistory = deleteSearchHistory
        }
    }

    public static let reducer = Reducer<Action, State> { action, state in
        var state = state
        switch action {
        case .loadModule:
            return state
        case let .selectEncoding(newEncoding):
            state.selectedEncoding = newEncoding
        case let .selectFavouriteLanguage(newLanguage):
            state.favouriteLanguage = newLanguage
        case let .gotAllEncodings(encodings):
            state.encodings = encodings
        case let .gotAllLanguages(languages):
            state.languages = languages
        case .deleteSearchHistory:
            break
        }
        return state
    }

    public static let middleware = EffectMiddleware<Action, Action, State, Dependencies>.onAction { action, state, context in
        switch action {
        case .loadModule:
            return
                Effect.sequence(
                    .selectFavouriteLanguage(context.dependencies.getFavouriteLanguage()),
                    .selectEncoding(context.dependencies.getSelectedEncoding()),
                    .gotAllEncodings(String.Encoding.allCases),
                    .gotAllLanguages(LanguageId.allCases)
                )

        case let .selectEncoding(newEncoding):
            return .fireAndForget { context.dependencies.saveSelectedEncoding(newEncoding) }
        case .deleteSearchHistory:
            return .fireAndForget { context.dependencies.deleteSearchHistory() }
        case let .selectFavouriteLanguage(newLanguage):
            return .fireAndForget { context.dependencies.saveFavouriteLanguage(newLanguage) }
        case .gotAllLanguages, .gotAllEncodings:
            return .doNothing
        }
    }
}
