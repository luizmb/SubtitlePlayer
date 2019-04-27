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

    public func biMap<Success2, Failure2: Error>(success: (Success) -> Success2, failure: (Failure) -> Failure2) -> Result<Success2, Failure2> {
        return map(success).mapError(failure)
    }

    public func biFlatMap<Success2, Failure2: Error>(success: (Success) -> Result<Success2, Failure2>,
                                                     failure: (Failure) -> Failure2) -> Result<Success2, Failure2> {
        switch self {
        case let .success(value):
            return success(value)
        case let .failure(error):
            return .failure(failure(error))
        }
    }

    public func biFlatMap<Success2, Failure2: Error>(success: (Success) -> Result<Success2, Failure>,
                                                     failure: (Failure) -> Failure2) -> Result<Success2, Failure2> {
        switch self {
        case let .success(value):
            return success(value).mapError(failure)
        case let .failure(error):
            return .failure(failure(error))
        }
    }

    public var value: Success? {
        guard case let .success(value) = self else { return nil }
        return value
    }

    public var error: Failure? {
        guard case let .failure(error) = self else { return nil }
        return error
    }
}
