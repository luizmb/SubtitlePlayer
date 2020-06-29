import CombineRex
import SwiftUI

@main
private struct SubtitlePlayerApp: App {
    private static let world = World.default
    @StateObject private var store = Self.world.store().asObservableViewModel(initialState: .empty)

    fileprivate var body: some Scene {
        MainScene(store: store)
    }
}

private struct MainScene: Scene {
    @ObservedObject fileprivate var store: ObservableViewModel<AppAction, AppState>
    @State private var sceneId = UUID()
    @Environment(\.scenePhase) private var scenePhase

    init(store: ObservableViewModel<AppAction, AppState>) {
        self.store = store
        store.dispatch(.scene(.active(id: sceneId)))
    }

    fileprivate var body: some Scene {
        WindowGroup {
            HomeView(viewModel: store)
        }.onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                store.dispatch(.scene(.active(id: sceneId)))
            case .inactive:
                store.dispatch(.scene(.inactive(id: sceneId)))
            case .background:
                store.dispatch(.scene(.background(id: sceneId)))
            @unknown default:
                break
            }
        }
    }
}
