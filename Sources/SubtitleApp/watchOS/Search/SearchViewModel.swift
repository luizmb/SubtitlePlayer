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
    searchButtonTap: () -> Void,
    queryButtonTap: (InterfaceControllerProtocol) -> Void,
    seasonButtonTap: (InterfaceControllerProtocol) -> Void,
    episodeButtonTap: (InterfaceControllerProtocol) -> Void,
    languageButtonTap: (InterfaceControllerProtocol) -> Void
)

public func searchViewModel(router: Router) -> (SearchViewModelOutput) -> SearchViewModelInput {
    return { output in
        let empty = "<empty>"
        var queryFilter: Filter<String> = .empty
        var seasonFilter: Filter<String> = .empty
        var episodeFilter: Filter<String> = .empty
        var languageFilter: Filter<LanguageId> = .empty

        let updateView = {
            output.queryLabelString(queryFilter.value(orEmpty: empty))
            output.seasonLabelString(seasonFilter.value(orEmpty: empty))
            output.episodeLabelString(episodeFilter.value(orEmpty: empty))
            output.languageLabelString(languageFilter.value(orEmpty: LanguageId.all).description)
            output.searchButtonEnabled(queryFilter.isSome)
        }

        return (
            awakeWithContext: { _ in },
            didAppear: { updateView() },
            willDisappear: { },
            searchButtonTap: { router.handle(.startSearch) },
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
                                          selectedIndex: seasonFilter.some.flatMap(suggestions.firstIndex(of:)),
                                          completion: { choice in
                    seasonFilter = choice ?? seasonFilter
                    updateView()
                }))
            },
            episodeButtonTap: { view in
                let suggestions = [empty] + (1...99).map(String.init)
                router.handle(.textPicker(parent: view,
                                          empty: empty,
                                          suggestions: suggestions,
                                          selectedIndex: episodeFilter.some.flatMap(suggestions.firstIndex(of:)),
                                          completion: { choice in
                    episodeFilter = choice ?? episodeFilter
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
