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

#if os(watchOS)
public typealias SearchViewModelInput = (
    awakeWithContext: (Any?) -> Void,
    didAppear: () -> Void,
    willDisappear: () -> Void,
    searchButtonTap: (Controller) -> Void,
    queryButtonTap: (Controller) -> Void,
    seasonButtonTap: (Controller) -> Void,
    episodeButtonTap: (Controller) -> Void,
    languageButtonTap: (Controller) -> Void
)
#endif

#if os(iOS)
public typealias SearchViewModelInput = (
    awakeWithContext: (Any?) -> Void,
    didAppear: () -> Void,
    willDisappear: () -> Void,
    searchButtonTap: (Controller) -> Void,
    queryTextChanged: (Controller, String?) -> Void,
    seasonButtonTap: (Controller) -> Void,
    episodeButtonTap: (Controller) -> Void,
    languageButtonTap: (Controller) -> Void
)
#endif

private let emptyString = "<empty>"
private let numberPickerSuggestions = [emptyString] + (1...99).map(String.init)
private let languagePickerSuggestions = LanguageId.allCases.map(^\.description).sorted()

public func searchViewModel(router: Router) -> Reader<Persistence, (SearchViewModelOutput) -> SearchViewModelInput> {
    return Reader { persistence in
        { output in
            var queryFilter: Filter<String> = .empty
            var seasonFilter: Filter<Int> = .empty
            var episodeFilter: Filter<Int> = .empty
            var languageFilter: Filter<LanguageId> =
                persistence.readLastLanguage().flatMap(LanguageId.init(rawValue:)).map(Filter.some) ?? .empty

            let updateView = {
                output.queryLabelString(queryFilter.value(orEmpty: emptyString))
                output.seasonLabelString(seasonFilter.map(String.init).value(orEmpty: emptyString))
                output.episodeLabelString(episodeFilter.map(String.init).value(orEmpty: emptyString))
                output.languageLabelString(languageFilter.map(^\.description).value(orEmpty: LanguageId.all.description))
                output.searchButtonEnabled(queryFilter.isSome)
            }

            #if os(watchOS)
            return (
                awakeWithContext: { _ in },
                didAppear: updateView,
                willDisappear: { },
                searchButtonTap: searchButtonTap(router: router,
                                                 queryFilter: { queryFilter },
                                                 seasonFilter: { seasonFilter },
                                                 episodeFilter: { episodeFilter },
                                                 languageFilter: { languageFilter }),
                queryButtonTap: queryButtonTap(router: router,
                                               persistence: persistence,
                                               updateQueryFilter: { queryFilter = $0 ?? queryFilter },
                                               updateView: updateView),
                seasonButtonTap: seasonButtonTap(router: router,
                                                 seasonFilter: { seasonFilter },
                                                 updateSeasonFilter: { seasonFilter = $0 ?? seasonFilter },
                                                 updateView: updateView),
                episodeButtonTap: episodeButtonTap(router: router,
                                                   episodeFilter: { episodeFilter },
                                                   updateEpisodeFilter: { episodeFilter = $0 ?? episodeFilter },
                                                   updateView: updateView),
                languageButtonTap: languageButtonTap(router: router,
                                                     persistence: persistence,
                                                     languageFilter: { languageFilter },
                                                     updateLanguageFilter: { languageFilter = $0 ?? languageFilter },
                                                     updateView: updateView)
            )
            #endif

            #if os(iOS)
            return (
                awakeWithContext: { _ in },
                didAppear: updateView,
                willDisappear: { },
                searchButtonTap: searchButtonTap(router: router,
                                                 queryFilter: { queryFilter },
                                                 seasonFilter: { seasonFilter },
                                                 episodeFilter: { episodeFilter },
                                                 languageFilter: { languageFilter }),
                queryTextChanged: queryTextChanged(updateQueryFilter: { queryFilter = $0 ?? queryFilter },
                                                   updateView: updateView),
                seasonButtonTap: seasonButtonTap(router: router,
                                                 seasonFilter: { seasonFilter },
                                                 updateSeasonFilter: { seasonFilter = $0 ?? seasonFilter },
                                                 updateView: updateView),
                episodeButtonTap: episodeButtonTap(router: router,
                                                   episodeFilter: { episodeFilter },
                                                   updateEpisodeFilter: { episodeFilter = $0 ?? episodeFilter },
                                                   updateView: updateView),
                languageButtonTap: languageButtonTap(router: router,
                                                     persistence: persistence,
                                                     languageFilter: { languageFilter },
                                                     updateLanguageFilter: { languageFilter = $0 ?? languageFilter },
                                                     updateView: updateView)
            )
            #endif
        }
    }
}

private func searchButtonTap(router: Router,
                             queryFilter: @escaping () -> Filter<String>,
                             seasonFilter: @escaping () -> Filter<Int>,
                             episodeFilter: @escaping () -> Filter<Int>,
                             languageFilter: @escaping () -> Filter<LanguageId>) -> (Controller) -> Void {
    return { view in
        let searchParameters = SearchParameters(
            query: queryFilter().some,
            episode: episodeFilter().some,
            season: seasonFilter().some,
            language: languageFilter().some ?? .all)
        router.handle(.startSearch(parent: view, searchParameters: searchParameters))
    }
}

#if os(watchOS)
private func queryButtonTap(router: Router,
                            persistence: Persistence,
                            updateQueryFilter: @escaping (Filter<String>?) -> Void,
                            updateView: @escaping () -> Void) -> (Controller) -> Void {
    return { view in
        let querySearches = persistence.readQuerySearches() ?? []
        router.handle(.dictation(
            parent: view,
            empty: emptyString,
            suggestions: [emptyString] + querySearches,
            completion: { choice in
                updateQueryFilter(choice)
                choice?.some.map {
                    if !querySearches.contains($0) {
                        persistence.saveQuerySearches([$0] + querySearches)
                    }
                }
                updateView()
        }))
    }
}
#endif

#if os(iOS)
private func queryTextChanged(updateQueryFilter: @escaping (Filter<String>?) -> Void,
                              updateView: @escaping () -> Void) -> (Controller, String?) -> Void {
    return { _, newText in
        let filter: Filter<String> = newText.map { $0.isEmpty ? .empty : .some($0) } ?? .empty
        updateQueryFilter(filter)
        updateView()
    }
}
#endif

private func seasonButtonTap(router: Router,
                             seasonFilter: @escaping () -> Filter<Int>,
                             updateSeasonFilter: @escaping (Filter<Int>?) -> Void,
                             updateView: @escaping () -> Void) -> (Controller) -> Void {
    return { view in
        router.handle(
            .textPicker(
                parent: view,
                empty: emptyString,
                suggestions: numberPickerSuggestions,
                selectedIndex: seasonFilter().map(String.init).some.flatMap(numberPickerSuggestions.firstIndex(of:)),
                completion: { choice in
                    updateSeasonFilter(choice?.some.flatMap(Int.init).map(Filter.some))
                    updateView()
                }
            )
        )
    }
}

private func episodeButtonTap(router: Router,
                              episodeFilter: @escaping () -> Filter<Int>,
                              updateEpisodeFilter: @escaping (Filter<Int>?) -> Void,
                              updateView: @escaping () -> Void) -> (Controller) -> Void {
    return { view in
        router.handle(
            .textPicker(
                parent: view,
                empty: emptyString,
                suggestions: numberPickerSuggestions,
                selectedIndex: episodeFilter().map(String.init).some.flatMap(numberPickerSuggestions.firstIndex(of:)),
                completion: { choice in
                    updateEpisodeFilter(choice?.some.flatMap(Int.init).map(Filter.some))
                    updateView()
                }
            )
        )
    }
}

private func languageButtonTap(router: Router,
                               persistence: Persistence,
                               languageFilter: @escaping () -> Filter<LanguageId>,
                               updateLanguageFilter: @escaping (Filter<LanguageId>?) -> Void,
                               updateView: @escaping () -> Void) -> (Controller) -> Void {
    return { view in
        router.handle(
            .textPicker(
                parent: view,
                empty: emptyString,
                suggestions: languagePickerSuggestions,
                selectedIndex: languageFilter().some.map(^\.description).flatMap(languagePickerSuggestions.firstIndex(of:)),
                completion: { choice in
                    let chosenLanguage = choice?.some.flatMap(LanguageId.init(description:))
                    chosenLanguage.map {
                        persistence.saveLastLanguage($0.rawValue)
                    }
                    updateLanguageFilter(chosenLanguage.map(Filter.some))
                    updateView()
                }
            )
        )
    }
}
