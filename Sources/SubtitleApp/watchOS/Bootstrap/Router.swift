import Foundation
import OpenSubtitlesDownloader
import WatchKit

public enum RouterEvent {
    case startSearch(parent: Controller, searchParameters: SearchParameters)
    case textPicker(parent: Controller, empty: String?, suggestions: [String], selectedIndex: Int?, completion: (Filter<String>?) -> Void)
    case dictation(parent: Controller, empty: String?, suggestions: [String], completion: (Filter<String>?) -> Void)
}

public protocol Router {
    func handle(_ event: RouterEvent)
}
