import CombineRex
import SwiftRex
import SwiftUI
import SubtitleDownloader

public struct SearchResultsView: View {
    @ObservedObject fileprivate var viewModel: ObservableViewModel<ViewEvent, ViewState>
    public var body: some View {
        List {
            ForEach(viewModel.state.resultItems) { item in
                HStack(spacing: 32) {
                    VStack(alignment: .leading) {
                        Text(item.title)
                            .font(.headline)

                        HStack {
                            Text(item.language)
                                .font(.subheadline)
                            Spacer()
                            Text(item.year)
                                .font(.subheadline)
                        }

                        Text(item.file)
                            .font(.caption2)
                    }

                    Button(action: { viewModel.dispatch(.tapButton(id: item.id)) }) {
                        Circle()
                            .frame(width: 44, height: 44)
                            .foregroundColor(item.buttonImageBackgroundColor)
                            .overlay(
                                Image(systemName: item.buttonImage)
                                    .foregroundColor(item.buttonImageForegroundColor)
                            )
                    }.accessibility(identifier: item.buttonAccessibilityText)
                }
            }
        }
        .alert(
            item: viewModel.bind(
                \.errorPopup,
                set: ViewEvent.toggleErrorAlert
            )
        ) { error in
            Alert(
                title: Text(error.title),
                message: Text(error.details),
                primaryButton:
                    Alert.Button.default(Text(error.retryButtonTitle)) {
                        viewModel.dispatch(.retry(id: error.id))
                    },
                secondaryButton:
                    Alert.Button.cancel(Text(error.cancelButtonTitle)) {
                        viewModel.dispatch(.toggleErrorAlert(nil))
                    }
            )
        }
        .navigationTitle(viewModel.state.navigationBarTitle)
    }
}

extension SearchResultsView {
    public init<S: StoreType>(store: S) where S.ActionType == DownloadModule.Action, S.StateType == DownloadModule.State {
        self = .init(
            viewModel: store.projection(
                action: Self.viewEventToAction,
                state: Self.stateToViewState
            ).asObservableViewModel(initialState: .empty)
        )
    }

    fileprivate static func stateToViewState(_ state: DownloadModule.State) -> ViewState {
        let downloadingIds = state.downloadingSubtitles.map(\.idSubtitleFile)
        let downloadedIds = state.downloadedSubtitles
        let downloadFailures = state.downloadFailures

        return ViewState(
            resultItems: state.lastSearchResults.value?.map { item in
                let isDownloaded = downloadedIds.contains(item.idSubtitleFile)
                let isDownloading = downloadingIds.contains(item.idSubtitleFile)
                let associatedError = downloadFailures.first(where: { error in item.idSubtitleFile == error.id })?.error.localizedDescription

                return ViewState.SearchResultItem(
                    id: item.idSubtitleFile,
                    title: item.movieName,
                    year: item.formattedSeriesString ?? String(item.movieYear),
                    language: item.languageName,
                    file: item.subFileName,

                    buttonImage:
                        associatedError != nil ? "exclamationmark.triangle.fill"
                        : isDownloaded ? "checkmark"
                        : isDownloading ? "stop.fill"
                        : "cloud.fill",

                    buttonImageForegroundColor:
                        associatedError != nil ? .white
                        : isDownloaded ? .white
                        : isDownloading ? .red
                        : .white,

                    buttonImageBackgroundColor:
                        associatedError != nil ? .red
                        : isDownloaded ? Color(UIColor(red: 0.3, green: 0.8, blue: 0.5, alpha: 1.0))
                        : isDownloading ? Color(UIColor(red: 0.9, green: 0.75, blue: 0.75, alpha: 1.0))
                        : Color(UIColor(red: 0.3, green: 0.5, blue: 1.0, alpha: 1.0)),

                    buttonAccessibilityText:
                        associatedError != nil ? "Download has failed, tap to see the error"
                        : isDownloaded ? "Play Subtitles"
                        : isDownloading ? "Cancel download"
                        : "Download",

                    associatedError: associatedError
                )
            } ?? [],
            errorPopup: state.currentErrorPopup.map {
                ViewState.ErrorPopup(
                    id: $0.id,
                    details: "The download has failed, technical details:\n\($0.error.localizedDescription)")
            }
        )
    }

    fileprivate static func viewEventToAction(_ viewEvent: ViewEvent) -> DownloadModule.Action? {
        switch viewEvent {
        case let .tapButton(id):
            return .selectSearchResultItem(id: id)
        case let .toggleErrorAlert(alert):
            return alert == nil ? .dismissErrorPopup : nil
        case let .retry(id):
            return .retry(id: id)
        }
    }
}

private enum ViewEvent {
    case tapButton(id: String)
    case toggleErrorAlert(ViewState.ErrorPopup?)
    case retry(id: String)
}

private struct ViewState: Equatable {
    let navigationBarTitle: String = "Search Results"
    let resultItems: [SearchResultItem]
    let errorPopup: ErrorPopup?

    static var empty: ViewState {
        .init(
            resultItems: [],
            errorPopup: nil
        )
    }

    struct SearchResultItem: Equatable, Identifiable {
        let id: String
        let title: String
        let year: String
        let language: String
        let file: String
        let buttonImage: String
        let buttonImageForegroundColor: Color
        let buttonImageBackgroundColor: Color
        let buttonAccessibilityText: String
        let associatedError: String?
    }

    struct ErrorPopup: Equatable, Identifiable {
        let id: String
        let title = "Download Error"
        let details: String
        let retryButtonTitle: String = "Retry"
        let cancelButtonTitle: String = "Cancel"
    }
}

#if DEBUG
struct SearchResultsViewPreview: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                SearchResultsView(
                    viewModel: .mock(state: .init(
                        resultItems: [
                            ViewState.SearchResultItem(
                                id: "1",
                                title: "IT Crowd S01E01",
                                year: "1899",
                                language: "🇧🇷 Portuguese Brazilian",
                                file: "it.crowd.s01e01.pt-BR.DIST.srt",
                                buttonImage: "cloud.fill",
                                buttonImageForegroundColor: .white,
                                buttonImageBackgroundColor: Color(UIColor(red: 0.3, green: 0.5, blue: 1.0, alpha: 1.0)),
                                buttonAccessibilityText: "Download",
                                associatedError: nil
                            ),
                            ViewState.SearchResultItem(
                                id: "2",
                                title: "IT Crowd S01E01",
                                year: "1899",
                                language: "🇵🇹 Portuguese",
                                file: "it.crowd.s01e01.pt-PT.DIST2.srt",
                                buttonImage: "stop.fill",
                                buttonImageForegroundColor: .red,
                                buttonImageBackgroundColor: Color(UIColor(red: 0.9, green: 0.75, blue: 0.75, alpha: 1.0)),
                                buttonAccessibilityText: "Cancel download",
                                associatedError: nil
                            ),
                            ViewState.SearchResultItem(
                                id: "3",
                                title: "IT Crowd S01E01",
                                year: "1899",
                                language: "🇺🇸 English US",
                                file: "it.crowd.s01e01.en.DIST1.srt",
                                buttonImage: "checkmark",
                                buttonImageForegroundColor: .white,
                                buttonImageBackgroundColor: Color(UIColor(red: 0.3, green: 0.8, blue: 0.5, alpha: 1.0)),
                                buttonAccessibilityText: "Play Subtitles",
                                associatedError: nil
                            ),
                            ViewState.SearchResultItem(
                                id: "4",
                                title: "IT Crowd S01E01",
                                year: "1899",
                                language: "🇺🇸 English US",
                                file: "it.crowd.s01e01.en.DIST1.srt",
                                buttonImage: "exclamationmark.triangle.fill",
                                buttonImageForegroundColor: .white,
                                buttonImageBackgroundColor: .red,
                                buttonAccessibilityText: "Download has failed, tap to see the error",
                                associatedError: "Some error"
                            )
                        ],
                        errorPopup: nil
                    ))
                )
            }
        }
    }
}
#endif

