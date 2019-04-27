import Foundation

extension Optional {
    public func apply<X, Y>(_ value: X) -> Y? where Wrapped == (X) -> Y {
        return self?(value)
    }
}
