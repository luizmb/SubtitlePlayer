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

public func zip<A, B>(_ a: @escaping () -> A, _ b: @escaping () -> B) -> () -> (A, B) {
    return { (a(), b()) }
}

public func zip<A, B, C>(_ a: @escaping () -> A, _ b: @escaping () -> B, _ c: @escaping () -> C) -> () -> (A, B, C) {
    return { (a(), b(), c()) }
}

public func zip<A, B, C, D>(_ a: @escaping () -> A, _ b: @escaping () -> B, _ c: @escaping () -> C, _ d: @escaping () -> D) -> () -> (A, B, C, D) {
    return { (a(), b(), c(), d()) }
}

public func zip<A, B, C, D, E>(_ a: @escaping () -> A, _ b: @escaping () -> B, _ c: @escaping () -> C, _ d: @escaping () -> D, _ e: @escaping () -> E) -> () -> (A, B, C, D, E) {
    return { (a(), b(), c(), d(), e()) }
}

public func zip<A, B>(_ tuple: (() -> A, () -> B)) -> () -> (A, B) {
    return { (tuple.0(), tuple.1()) }
}

public func zip<A, B, C>(_ tuple: (() -> A, () -> B, () -> C)) -> () -> (A, B, C) {
    return { (tuple.0(), tuple.1(), tuple.2()) }
}

public func zip<A, B, C, D>(_ tuple: (() -> A, () -> B, () -> C, () -> D)) -> () -> (A, B, C, D) {
    return { (tuple.0(), tuple.1(), tuple.2(), tuple.3()) }
}

public func zip<A, B, C, D, E>(_ tuple: (() -> A, () -> B, () -> C, () -> D, () -> E)) -> () -> (A, B, C, D, E) {
    return { (tuple.0(), tuple.1(), tuple.2(), tuple.3(), tuple.4()) }
}

public func zip<A, B, Z>(_ a: @escaping (Z) -> A, _ b: @escaping (Z) -> B) -> (Z) -> (A, B) {
    return { (a($0), b($0)) }
}

public func zip<A, B, C, Z>(_ a: @escaping (Z) -> A, _ b: @escaping (Z) -> B, _ c: @escaping (Z) -> C) -> (Z) -> (A, B, C) {
    return { (a($0), b($0), c($0)) }
}

public func zip<A, B, C, D, Z>(_ a: @escaping (Z) -> A, _ b: @escaping (Z) -> B, _ c: @escaping (Z) -> C, _ d: @escaping (Z) -> D) -> (Z) -> (A, B, C, D) {
    return { (a($0), b($0), c($0), d($0)) }
}

public func zip<A, B, C, D, E, Z>(_ a: @escaping (Z) -> A, _ b: @escaping (Z) -> B, _ c: @escaping (Z) -> C, _ d: @escaping (Z) -> D, _ e: @escaping (Z) -> E) -> (Z) -> (A, B, C, D, E) {
    return { (a($0), b($0), c($0), d($0), e($0)) }
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
