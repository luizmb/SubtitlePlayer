import Foundation

public typealias PlayerViewModelOutput = (
)

public typealias PlayerViewModelInput = (
    awakeWithContext: (Any?) -> Void,
    didAppear: () -> Void,
    willDisappear: () -> Void
)

public func playerViewModel(router: Router) -> (PlayerViewModelOutput) -> PlayerViewModelInput {
    return { output in
        return (
            awakeWithContext: { _ in },
            didAppear: { },
            willDisappear: { }
        )
    }
}
