import CombineRex
import SwiftRex
import SwiftUI
import SubtitleDownloader

public struct SearchView: View {
    @ObservedObject fileprivate var viewModel: ObservableViewModel<ViewEvent, ViewState>

    public var body: some View {
        Form {
            Section(header: Text(viewModel.state.sectionHeaderMedia)) {
                HStack {
                    TextField(viewModel.state.queryTitle, text: viewModel.bind(\.queryValue, set: ViewEvent.setQueryValue))
                        .keyboardType(.default)

                    Button(action: { viewModel.dispatch(.tapHistory) }) {
                        HStack {
                            Image(systemName: viewModel.state.queryHistoryImage)
                            Text(viewModel.state.queryHistoryTitle)
                        }
                    }
                }

                TextField(viewModel.state.seasonTitle, text: viewModel.bind(\.seasonValue, set: ViewEvent.setSeasonValue))
                    .keyboardType(.numberPad)

                TextField(viewModel.state.episodeTitle, text: viewModel.bind(\.episodeValue, set: ViewEvent.setEpisodeValue))
                    .keyboardType(.numberPad)
            }

            Picker(viewModel.state.languageTitle, selection: viewModel.bind(\.languageSelected, set: ViewEvent.selectLanguage)) {
                ForEach(viewModel.state.languageOptions) { language in
                    Text(language.title)
                        .tag(language.id)
                }
            }

            if let errorText = viewModel.state.errorText {
                Section(
                    footer: HStack(alignment: .firstTextBaseline) {
                        Image(systemName: viewModel.state.errorImage)
                        Text(errorText)
                    }.foregroundColor(.red)
                ) { EmptyView() }
            }
        }
        .onAppear { viewModel.dispatch(.appear) }
        .navigationBarItems(trailing: Button(viewModel.state.searchButtonTitle) {
            viewModel.dispatch(.tapSearch)
        })
        .navigationTitle(viewModel.state.navigationBarTitle)
    }
}

extension SearchView {
    public init<S: StoreType>(store: S) where S.ActionType == DownloadModule.Action, S.StateType == DownloadModule.State {
        self = .init(
            viewModel: store.projection(
                action: Self.viewEventToAction,
                state: Self.stateToViewState
            ).asObservableViewModel(initialState: .empty)
        )
    }

    fileprivate static func stateToViewState(_ state: DownloadModule.State) -> ViewState {
        ViewState(
            queryValue: state.currentQueryFilter ?? "",
            seasonValue: state.currentSeasonFilter ?? "",
            episodeValue: state.currentEpisodeFilter ?? "",
            languageSelected: state.currentLanguageFilter.rawValue,
            languageOptions: state.languages.map {
                ViewState.LanguageOption(id: $0.rawValue, title: $0.description)
            },
            errorText: state.lastSearchResults.error.map {
                "Error while searching, please check your connection and try again.\n" +
                "\n" +
                "Technical details:\n" +
                "\($0)"
            }
        )
    }

    fileprivate static func viewEventToAction(_ viewEvent: ViewEvent) -> DownloadModule.Action? {
        switch viewEvent {
        case .appear:
            return .selectFavouriteLanguage

        case let .setQueryValue(newQueryValue):
            return .setQueryValue(newQueryValue)

        case let .setSeasonValue(newSeasonValue):
            return .setSeasonValue(newSeasonValue)

        case let .setEpisodeValue(newEpisodeValue):
            return .setEpisodeValue(newEpisodeValue)

        case let .selectLanguage(languageId):
            guard let language = LanguageId(rawValue: languageId) else { return nil }
            return .selectLanguage(language)

        case .tapSearch:
            return .search

        case .tapHistory:
            return .showQueryHistory
        }
    }
}

private enum ViewEvent {
    case appear
    case setQueryValue(String)
    case setSeasonValue(String)
    case setEpisodeValue(String)
    case selectLanguage(String)
    case tapHistory
    case tapSearch
}

private struct ViewState: Equatable {
    let navigationBarTitle: String = "Subtitle Search"
    let sectionHeaderMedia: String = "Media"
    let queryTitle: String = "Query"
    let queryValue: String
    let queryHistoryImage: String = "arrow.counterclockwise.circle"
    let queryHistoryTitle: String = "History"
    let seasonTitle: String = "Season"
    let seasonValue: String
    let episodeTitle: String = "Episode"
    let episodeValue: String
    let languageTitle: String = "Language"
    let languageSelected: String
    let languageOptions: [LanguageOption]
    let searchButtonTitle: String = "Search"
    let errorImage: String = "xmark.circle.fill"
    let errorText: String?

    static var empty: ViewState {
        .init(
            queryValue: "",
            seasonValue: "",
            episodeValue: "",
            languageSelected: "all",
            languageOptions: [],
            errorText: nil
        )
    }

    struct LanguageOption: Identifiable, Equatable {
        let id: String
        let title: String
    }
}

#if DEBUG
struct SearchViewPreview: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                SearchView(viewModel: .mock(state: .empty))
            }
            NavigationView {
                SearchView(
                    viewModel: .mock(
                        state: SearchView.stateToViewState(
                            DownloadModule.State(
                                currentQueryFilter: "IT Crowd",
                                currentSeasonFilter: "1",
                                currentEpisodeFilter: "9",
                                languages: LanguageId.allCases,
                                currentLanguageFilter: .all,
                                favouriteLanguage: .all,
                                lastSearchResults: .failure(NetworkError.invalidStatusCode(500)),
                                downloadingSubtitles: [],
                                downloadFailures: [],
                                downloadedSubtitles: [],
                                currentErrorPopup: nil,
                                queryHistory: [],
                                showingQueryHistory: false,
                                isSearching: false
                            )
                        )
                    )
                )
            }
        }
    }
}
#endif

