import Common
import Foundation
import OpenSubtitlesDownloader
import WatchKit

public final class MainRouter {
    public static func start() {
        let router = MainRouter()
        let searchViewContext =
            ViewModel(bind: searchViewModel(router: router).contramap(^\.persistence).inject(Environment.current)).asContext
        let playerViewContext =
            ViewModel(bind: playerViewModel(router: router)).asContext

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
        case let .startSearch(parent, searchParameters):
            let searchResultViewContext = ViewModel(bind: searchResultViewModel(router: self, searchParameters: searchParameters, completion: { subtitle in print(subtitle) }).contramap(^\.urlSession, ^\.openSubtitlesUserAgent).inject(Environment.current)).asContext
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
        }
    }
}

extension Environment {
    fileprivate static var current: Environment = Environment(
        now: Date.init,
        urlSession: { URLSession.shared },
        openSubtitlesUserAgent: { UserAgent(rawValue: "TemporaryUserAgent") },
        fileManager: FileManager.init,
        gzip: { Gzip.self },
        persistence: { UserDefaults.standard }
    )
}
