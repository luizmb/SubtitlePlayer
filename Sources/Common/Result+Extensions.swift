import Foundation

extension Result {
    public func fold<Folded>(ifSuccess: (Success) -> Folded, ifFailure: (Failure) -> Folded) -> Folded {
        switch self {
        case let .success(value): return ifSuccess(value)
        case let .failure(error): return ifFailure(error)
        }
    }

    public func analysis(ifSuccess: (Success) -> Void, ifFailure: (Failure) -> Void) {
        fold(ifSuccess: ifSuccess, ifFailure: ifFailure)
    }
}
