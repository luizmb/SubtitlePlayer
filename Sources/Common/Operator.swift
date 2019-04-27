import Foundation

prefix operator ^
public prefix func ^ <Root, Value>(keyPath: KeyPath<Root, Value>) -> (Root) -> Value {
    return { root in
        root[keyPath: keyPath]
    }
}

precedencegroup ForwardComposition {
    associativity: left
}

infix operator >>>: ForwardComposition
public func >>> <A, B, C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> (A) -> C {
    return { a in
        g(f(a))
    }
}

public func identity<A>(_ a: A) -> A {
    return a
}

public func zip<A, B>(_ a: A?, _ b: B?) -> (A, B)? {
    guard let a = a, let b = b else { return nil }
    return (a, b)
}

public func curry<A, B, C>(_ fn: @escaping (A, B) -> C) -> ((A) -> ((B) -> C)) {
    return { a in { b in fn(a, b) } }
}

public func uncurry<A, B, C>(_ fn: @escaping (A) -> ((B) -> C)) -> ((A, B) -> C) {
    return { (a, b) in fn(a)(b) }
}

public func flip<A, B, C>(_ fn: @escaping (A, B) -> C) -> ((B, A) -> C) {
    return { b, a in fn(a, b) }
}

public func run<A>(_ fn: @escaping () -> A) -> A {
    return fn()
}

public func partialApply<A, B, C>(_ fn: @escaping (A, B) -> C, _ a: A) -> ((B) -> C) {
    return curry(fn)(a)
}

public func const<A, B>(_ b: B) -> ((A) -> B) {
    return { _ in b }
}

public func lazy<A>(_ a: A) -> () -> A {
    return { a }
}
