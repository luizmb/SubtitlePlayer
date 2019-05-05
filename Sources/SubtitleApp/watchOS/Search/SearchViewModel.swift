import Common
import Foundation
import OpenSubtitlesDownloader

public typealias SearchViewModelOutput = (
    queryLabelString: (String) -> Void,
    seasonLabelString: (String) -> Void,
    episodeLabelString: (String) -> Void,
    languageLabelString: (String) -> Void,
    searchButtonEnabled: (Bool) -> Void
)

public typealias SearchViewModelInput = (
    awakeWithContext: (Any?) -> Void,
    didAppear: () -> Void,
    willDisappear: () -> Void,
    searchButtonTap: (InterfaceControllerProtocol) -> Void,
    queryButtonTap: (InterfaceControllerProtocol) -> Void,
    seasonButtonTap: (InterfaceControllerProtocol) -> Void,
    episodeButtonTap: (InterfaceControllerProtocol) -> Void,
    languageButtonTap: (InterfaceControllerProtocol) -> Void
)

public func searchViewModel(router: Router) -> (SearchViewModelOutput) -> SearchViewModelInput {
    return { output in
        let empty = "<empty>"
        var queryFilter: Filter<String> = .empty
        var seasonFilter: Filter<Int> = .empty
        var episodeFilter: Filter<Int> = .empty
        var languageFilter: Filter<LanguageId> = .empty

        let updateView = {
            output.queryLabelString(queryFilter.value(orEmpty: empty))
            output.seasonLabelString(seasonFilter.map(String.init).value(orEmpty: empty))
            output.episodeLabelString(episodeFilter.map(String.init).value(orEmpty: empty))
            output.languageLabelString(languageFilter.map(^\.description).value(orEmpty: LanguageId.all.description))
            output.searchButtonEnabled(queryFilter.isSome)
        }

        return (
            awakeWithContext: { _ in },
            didAppear: { updateView() },
            willDisappear: { },
            searchButtonTap: { view in
                let searchParameters = SearchParameters(
                    query: queryFilter.some,
                    episode: episodeFilter.some,
                    season: seasonFilter.some,
                    language: languageFilter.some ?? .all)
                router.handle(.startSearch(parent: view, searchParameters: searchParameters))
            },
            queryButtonTap: { view in
                router.handle(.dictation(parent: view,
                                         empty: empty,
                                         suggestions: [empty, queryFilter.some].compactMap { $0 },
                                         completion: { choice in
                    queryFilter = choice ?? queryFilter
                    updateView()
                }))
            },
            seasonButtonTap: { view in
                let suggestions = [empty] + (1...99).map(String.init)
                router.handle(.textPicker(parent: view,
                                          empty: empty,
                                          suggestions: suggestions,
                                          selectedIndex: seasonFilter.map(String.init).some.flatMap(suggestions.firstIndex(of:)),
                                          completion: { choice in
                    seasonFilter = choice?.some.flatMap(Int.init).map(Filter.some) ?? seasonFilter
                    updateView()
                }))
            },
            episodeButtonTap: { view in
                let suggestions = [empty] + (1...99).map(String.init)
                router.handle(.textPicker(parent: view,
                                          empty: empty,
                                          suggestions: suggestions,
                                          selectedIndex: episodeFilter.map(String.init).some.flatMap(suggestions.firstIndex(of:)),
                                          completion: { choice in
                    episodeFilter = choice?.some.flatMap(Int.init).map(Filter.some) ?? episodeFilter
                    updateView()
                }))
            },
            languageButtonTap: { view in
                let suggestions = LanguageId.allCases.map(^\.description).sorted()
                router.handle(.textPicker(parent: view,
                                          empty: empty,
                                          suggestions: suggestions,
                                          selectedIndex: languageFilter.some.map(^\.description).flatMap(suggestions.firstIndex(of:)),
                                          completion: { choice in
                    languageFilter = choice?.some.flatMap(LanguageId.init(description:)).map(Filter.some) ?? languageFilter
                    updateView()
                }))
            }
        )
    }
}
