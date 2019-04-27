import Foundation

extension Optional {
    public func apply<X, Y>(_ value: X) -> Y? where Wrapped == (X) -> Y {
        return self?(value)
    }

    public func toResult<E: Error>(orError: @autoclosure () -> E) -> Result<Wrapped, E> {
        return map(Result.success) ?? .failure(orError())
    }
}

extension Optional {
    public func fold<Folded>(ifSome: (Wrapped) -> Folded, ifNone: () -> Folded) -> Folded {
        switch self {
        case let .some(value): return ifSome(value)
        case .none: return ifNone()
        }
    }

    public func analysis(ifSome: (Wrapped) -> Void, ifNone: () -> Void) {
        fold(ifSome: ifSome, ifNone: ifNone)
    }
}
