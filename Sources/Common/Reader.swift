import Foundation

public struct Reader<E, A> {
    public let run: (E) -> A

    public init(_ run: @escaping (E) -> A) {
        self.run = run
    }

    public func map<A2>(_ fn: @escaping (A) -> A2) -> Reader<E, A2> {
        return Reader<E, A2> { environment in
            fn(self.run(environment))
        }
    }

    public func contramap<E2>(_ fn: @escaping (E2) -> E) -> Reader<E2, A> {
        return Reader<E2, A> { environment2 in
            self.run(fn(environment2))
        }
    }

    public func flatMap<A2>(_ fn: @escaping (A) -> Reader<E, A2>) -> Reader<E, A2> {
        return Reader<E, A2> { environment in
            fn(self.run(environment)).run(environment)
        }
    }
}
