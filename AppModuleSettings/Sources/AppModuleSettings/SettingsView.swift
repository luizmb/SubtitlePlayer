import CombineRex
import SwiftRex
import SwiftUI
import SubtitleDownloader

public struct SettingsView: View {
    @ObservedObject fileprivate var viewModel: ObservableViewModel<ViewEvent, ViewState>

    public var body: some View {
        Form {
            Section(header: Text(viewModel.state.sectionHeaderPreferences)) {
                Picker(
                    viewModel.state.encodingTitle,
                    selection: viewModel.bind(
                        \.encodingSelected,
                        set: ViewEvent.selectEncoding
                    )
                ) {
                    ForEach(viewModel.state.encodingOptions) { option in
                        Text(option.title)
                            .tag(option.id)
                    }
                }

                Picker(
                    viewModel.state.favouriteLanguageTitle,
                    selection: viewModel.bind(
                        \.favouriteLanguageSelected,
                        set: ViewEvent.selectFavouriteLanguage
                    )
                ) {
                    ForEach(viewModel.state.favouriteLanguageOptions) { option in
                        Text(option.title)
                            .tag(option.id)
                    }
                }
            }

            Section {
                Button(viewModel.state.buttonDeleteSearches) {
                    viewModel.dispatch(.deleteSearchHistory)
                }.foregroundColor(.red)
            }
        }
        .navigationTitle(viewModel.state.navigationBarTitle)
    }
}

extension SettingsView {
    public init<S: StoreType>(store: S) where S.ActionType == SettingsModule.Action, S.StateType == SettingsModule.State {
        self = .init(
            viewModel: store.projection(
                action: { viewEvent in
                    switch viewEvent {
                    case .deleteSearchHistory:
                        return .deleteSearchHistory
                    case let .selectEncoding(encodingId):
                        return .selectEncoding(String.Encoding(rawValue: encodingId))
                    case let .selectFavouriteLanguage(languageId):
                        guard let language = LanguageId(rawValue: languageId) else { return nil }
                        return .selectFavouriteLanguage(language)
                    }
                },
                state: { state in
                    ViewState(
                        encodingSelected: state.selectedEncoding.rawValue,
                        encodingOptions: state.encodings.map {
                            ViewState.EncodingOption(
                                id: $0.rawValue,
                                title: $0.description.isEmpty ? $0.shortName ?? "" : $0.description
                            )
                        },
                        favouriteLanguageSelected: state.favouriteLanguage.rawValue,
                        favouriteLanguageOptions: state.languages.map {
                            ViewState.FavouriteLanguageOption(
                                id: $0.rawValue,
                                title: $0.description
                            )
                        }
                    )
                }
            ).asObservableViewModel(initialState: .empty)
        )
    }
}

private enum ViewEvent {
    case selectEncoding(UInt)
    case selectFavouriteLanguage(String)
    case deleteSearchHistory
}

private struct ViewState: Equatable {
    let navigationBarTitle: String = "Settings"
    let sectionHeaderPreferences: String = "Preferences"
    let encodingTitle: String = "Encoding"
    let encodingSelected: UInt
    let encodingOptions: [EncodingOption]
    let favouriteLanguageTitle: String = "Favourite Language"
    let favouriteLanguageSelected: String
    let favouriteLanguageOptions: [FavouriteLanguageOption]
    let buttonDeleteSearches: String = "Delete search history"

    fileprivate static var empty: ViewState {
        .init(
            encodingSelected: String.Encoding.utf8.rawValue,
            encodingOptions: [],
            favouriteLanguageSelected: "all",
            favouriteLanguageOptions: []
        )
    }

    struct EncodingOption: Identifiable, Equatable {
        let id: UInt
        let title: String
    }

    struct FavouriteLanguageOption: Identifiable, Equatable {
        let id: String
        let title: String
    }
}

#if DEBUG
struct SettingsViewPreview: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                SettingsView(viewModel: .mock(state: .empty))
            }
        }
    }
}
#endif

