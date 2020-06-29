import CombineRex
import SwiftRex
import SwiftUI
import SubtitleDownloader

public struct SearchHistoryView: View {
    @ObservedObject fileprivate var viewModel: ObservableViewModel<ViewEvent, ViewState>

    public var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.state.history, id: \.self) { historyEntry in
                    Text(historyEntry)
                }.onDelete { indexSet in
                    viewModel.dispatch(.removeEntry(indexSet))
                }
            }
            .navigationBarItems(
                leading: Button(viewModel.state.dismissButtonTitle) {
                    viewModel.dispatch(.tapCancel)
                },
                trailing: Button(viewModel.state.cleanHistoryButtonTitle) {
                    viewModel.dispatch(.cleanHistory)
                }
            )
        }
    }
}

extension SearchHistoryView {
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
            history: state.queryHistory
        )
    }

    fileprivate static func viewEventToAction(_ viewEvent: ViewEvent) -> DownloadModule.Action? {
        switch viewEvent {
        case let .setQueryValue(newQueryValue):
            return .setQueryValue(newQueryValue)
        case let .removeEntry(indexSet):
            return .removeHistoryEntry(indexSet)
        case .cleanHistory:
            return .cleanHistory
        case .tapCancel:
            return .dismissHistory
        }
    }
}

private enum ViewEvent {
    case setQueryValue(String)
    case removeEntry(IndexSet)
    case cleanHistory
    case tapCancel
}

private struct ViewState: Equatable {
    let dismissButtonTitle: String = "Close"
    let cleanHistoryButtonTitle: String = "Clean History"
    let history: [String]

    static var empty: ViewState {
        .init(
            history: []
        )
    }
}

#if DEBUG
struct SearchHistoryViewPreview: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                SearchHistoryView(viewModel: .mock(state: .empty))
            }
            NavigationView {
                SearchHistoryView(
                    viewModel: .mock(
                        state: SearchHistoryView.stateToViewState(
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

