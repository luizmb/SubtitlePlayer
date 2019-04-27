import Foundation

extension Optional {
    public func apply<X, Y>(_ value: X) -> Y? where Wrapped == (X) -> Y {
        return self?(value)
    }

    public func toResult<E: Error>(orError: @autoclosure () -> E) -> Result<Wrapped, E> {
        return map(Result.success) ?? .failure(orError())
    }
}
