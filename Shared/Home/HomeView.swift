import AppModuleDownload
import AppModuleSettings
import Combine
import CombineRex
import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: ObservableViewModel<AppAction, AppState>

    var body: some View {
        TabView {
            Text("Player")
                .tabItem {
                    Image(systemName: "play.fill")
                    Text("Player")
                }

            NavigationView {
                AppModuleDownload.SearchView(
                    store: viewModel.projection(
                        action: AppAction.download,
                        state: \.download
                    )
                )
            }
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Search")
            }

            NavigationView {
                AppModuleSettings.SettingsView(
                    store: viewModel.projection(
                        action: AppAction.settings,
                        state: \.settings
                    )
                )
            }
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
        }
    }
}

struct HomeViewPreview: PreviewProvider {
    static var previews: some View {
        Group {
            HomeView(viewModel: .mock(state: .empty))
        }
    }
}
