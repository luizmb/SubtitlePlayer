import Foundation

public typealias SearchResultViewModelOutput = (
)

public typealias SearchResultViewModelInput = (
    awakeWithContext: (Any?) -> Void,
    didAppear: () -> Void,
    willDisappear: () -> Void
)

public func searchResultViewModel(router: Router) -> (SearchResultViewModelOutput) -> SearchResultViewModelInput {
    return { output in
        return (
            awakeWithContext: { _ in },
            didAppear: { },
            willDisappear: { }
        )
    }
}
