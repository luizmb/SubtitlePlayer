import Foundation

public typealias SearchViewModelOutput = (
    presentQueryDictation: ([String]) -> Void,
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
    queryButtonTap: () -> Void,
    seasonButtonTap: () -> Void,
    episodeButtonTap: () -> Void,
    languageButtonTap: () -> Void,
    queryTextChanged: (String?) -> Void
)

public func searchViewModel(router: Router) -> (SearchViewModelOutput) -> SearchViewModelInput {
    return { output in
        var currentQuery: String? = nil
        var currentSeason: String? = nil
        var currentEpisode: String? = nil
        var currentLanguage: String? = nil

        let updateView = {
            output.queryLabelString(currentQuery ?? "<empty>")
            output.seasonLabelString(currentSeason ?? "<empty>")
            output.episodeLabelString(currentEpisode ?? "<empty>")
            output.languageLabelString(currentLanguage ?? "All")
            output.searchButtonEnabled(currentQuery != nil)
        }

        return (
            awakeWithContext: { _ in },
            didAppear: { updateView() },
            willDisappear: { },
            searchButtonTap: { router.handle(.startSearch) },
            queryButtonTap: { output.presentQueryDictation(["<empty>"]) },
            seasonButtonTap: { print("setSeasonButtonTap") },
            episodeButtonTap: { print("setEpisodeButtonTap") },
            languageButtonTap: { print("setLanguageButtonTap") },
            queryTextChanged: { text in
                currentQuery = text ?? currentQuery
                updateView()
            }
        )
    }
}
