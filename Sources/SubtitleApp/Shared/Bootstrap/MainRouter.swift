import Common
import Foundation
import OpenSubtitlesDownloader

extension Environment {
    fileprivate static var current: Environment = Environment(
        now: { Date.init },
        urlSession: { URLSession.shared },
        openSubtitlesUserAgent: { UserAgent(rawValue: "TemporaryUserAgent") },
        fileManager: FileManager.init,
        gzip: { Gzip.self },
        persistence: { UserDefaults.standard }
    )
}

#if os(watchOS)
import WatchKit

public final class MainRouter {
    public static func start() {
        createRootPages(router: MainRouter())
    }
}

extension MainRouter: Router {
    public func handle(_ event: RouterEvent) {
        switch event {
        case let .startSearch(parent, searchParameters):
            let searchResultViewContext = ViewModel(bind: searchResultViewModel(router: self, searchParameters: searchParameters)
                .contramap(^\.urlSession, ^\.openSubtitlesUserAgent, ^\.fileManager, ^\.gzip, ^\.persistence)
                .inject(Environment.current))
                .asContext
            parent.presentController(withName: SearchResultViewController.name, context: searchResultViewContext)
        case let .textPicker(parent, empty, suggestions, selectedIndex, completion):
            let textPickerViewContext = ViewModel(bind: textPickerViewModel(items: suggestions, selectedIndex: selectedIndex, completion: { text in
                completion(text.map { $0 == empty ? Filter.empty : .some($0) })
            })).asContext
            parent.presentController(withName: TextPickerViewController.name, context: textPickerViewContext)
        case let .dictation(parent, empty, suggestions, completion):
            parent.presentTextInputController(withSuggestions: suggestions, allowedInputMode: .plain) { text in
                completion((text?.first as? String).map { $0 == empty ? Filter.empty : .some($0) })
            }
        case let .play(parent, subtitle):
            let playerViewContext = ViewModel(bind: playerViewModel(router: self, subtitle: subtitle).contramap(^\.now).inject(Environment.current)).asContext
            parent.presentController(withName: PlayerViewController.name, context: playerViewContext)
        case .searchForm:
            createRootPages(router: self, index: 1)
        }
    }
}

func createRootPages(router: MainRouter, index: Int = 0) {
    let localStorage = localStorageViewModel(router: router).contramap(^\.fileManager, ^\.persistence).inject(Environment.current)
    let search = searchViewModel(router: router).contramap(^\.persistence).inject(Environment.current)
    let settings = settingsViewModel(router: router).contramap(^\.persistence).inject(Environment.current)

    WKInterfaceController.reloadRootPageControllers(
        withNames: [
            LocalStorageViewController.name,
            SearchViewController.name,
            SettingsViewController.name
        ],
        contexts: [
            ViewModel(bind: localStorage).asContext,
            ViewModel(bind: search).asContext,
            ViewModel(bind: settings).asContext
        ],
        orientation: .horizontal,
        pageIndex: index
    )
}
#endif

#if os(iOS)
import UIKit

public final class MainRouter {
    public static func start() -> UIWindow {
        let window = UIWindow()
        window.rootViewController = createRootPages(router: MainRouter())
        window.makeKeyAndVisible()
        return window
    }
}

extension MainRouter: Router {
    public func handle(_ event: RouterEvent) {
        switch event {
        case let .startSearch(parent, searchParameters): break
//            let searchResultViewContext = ViewModel(bind: searchResultViewModel(router: self, searchParameters: searchParameters)
//                .contramap(^\.urlSession, ^\.openSubtitlesUserAgent, ^\.fileManager, ^\.gzip, ^\.persistence)
//                .inject(Environment.current))
//                .asContext
//            parent.presentController(withName: SearchResultViewController.name, context: searchResultViewContext)
        case let .textPicker(parent, empty, suggestions, selectedIndex, completion): break
//            let textPickerViewContext = ViewModel(bind: textPickerViewModel(items: suggestions, selectedIndex: selectedIndex, completion: { text in
//                completion(text.map { $0 == empty ? Filter.empty : .some($0) })
//            })).asContext
//            parent.presentController(withName: TextPickerViewController.name, context: textPickerViewContext)
        case let .play(parent, subtitle): break
//            let playerViewContext = ViewModel(bind: playerViewModel(router: self, subtitle: subtitle).contramap(^\.now).inject(Environment.current)).asContext
//            parent.presentController(withName: PlayerViewController.name, context: playerViewContext)
        case .searchForm: break
//            createRootPages(router: self, index: 1)
        }
    }
}

func createRootPages(router: MainRouter) -> UIViewController {
    let localStorage = localStorageViewModel(router: router).contramap(^\.fileManager, ^\.persistence).inject(Environment.current)
    let search = searchViewModel(router: router).contramap(^\.persistence).inject(Environment.current)
    let settings = settingsViewModel(router: router).contramap(^\.persistence).inject(Environment.current)

    let pages = UIPageViewController()
    pages.setViewControllers(
        [],
        direction: .forward,
        animated: true
    ) { _ in
//        withNames: [
//            LocalStorageViewController.name,
//            SearchViewController.name,
//            SettingsViewController.name
//        ],
//        contexts: [
//            ViewModel(bind: localStorage).asContext,
//            ViewModel(bind: search).asContext,
//            ViewModel(bind: settings).asContext
//        ],
    }

    return pages
}
#endif
