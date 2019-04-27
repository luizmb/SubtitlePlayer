import Foundation

prefix operator ^
public prefix func ^ <Root, Value>(keyPath: KeyPath<Root, Value>) -> (Root) -> Value {
    return { root in
        root[keyPath: keyPath]
    }
}

public func identity<A>(_ a: A) -> A {
    return a
}

public func zip<A, B>(_ a: A?, _ b: B?) -> (A, B)? {
    guard let a = a, let b = b else { return nil }
    return (a, b)
}
