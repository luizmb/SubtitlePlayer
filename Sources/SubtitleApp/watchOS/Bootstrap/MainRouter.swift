import Foundation
import WatchKit

public final class MainRouter {
    public static func start() {
        let router = MainRouter()
        let searchViewContext = ViewModel(bind: searchViewModel(router: router)).asContext
        let playerViewContext = ViewModel(bind: playerViewModel(router: router)).asContext

        WKInterfaceController.reloadRootPageControllers(
            withNames: [SearchViewController.name, PlayerViewController.name],
            contexts: [searchViewContext, playerViewContext],
            orientation: .horizontal,
            pageIndex: 0
        )
    }
}

extension MainRouter: Router {
    public func handle(_ event: RouterEvent) {
        switch event {
        case .startSearch:
            print("Start Search")
        }
    }
}
