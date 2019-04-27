import Foundation

public class Reader<E, A> {
    public let inject: (E) -> A

    public init(_ inject: @escaping (E) -> A) {
        self.inject = inject
    }

    public func map<A2>(_ fn: @escaping (A) -> A2) -> Reader<E, A2> {
        return Reader<E, A2> { environment in
            fn(self.inject(environment))
        }
    }

    public func contramap<E2>(_ fn: @escaping (E2) -> E) -> Reader<E2, A> {
        return Reader<E2, A> { environment2 in
            self.inject(fn(environment2))
        }
    }

    public func flatMap<A2>(_ fn: @escaping (A) -> Reader<E, A2>) -> Reader<E, A2> {
        return Reader<E, A2> { environment in
            fn(self.inject(environment)).inject(environment)
        }
    }
}

extension Reader {
    public static func pure(_ a: A) -> Reader {
        return Reader { _ in a }
    }
}
