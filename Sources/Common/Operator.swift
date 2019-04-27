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
