import Foundation

public enum RouterEvent {
    case startSearch
}

public protocol Router {
    func handle(_ event: RouterEvent)
}
