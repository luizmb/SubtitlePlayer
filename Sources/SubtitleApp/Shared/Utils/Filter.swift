import Foundation

public enum Filter<T> {
    case empty
    case some(T)
}

extension Filter {
    public func map<U>(_ fn: @escaping (T) -> U) -> Filter<U> {
        switch self {
        case .empty: return .empty
        case let .some(value): return .some(fn(value))
        }
    }

    public func flatMap<U>(_ fn: @escaping (T) -> Filter<U>) -> Filter<U> {
        switch self {
        case .empty: return .empty
        case let .some(value): return fn(value)
        }
    }
}

extension Filter {
    public func value(orEmpty: T) -> T {
        switch self {
        case .empty: return orEmpty
        case let .some(value): return value
        }
    }
}

extension Filter {
    public var isEmpty: Bool {
        guard case .empty = self else { return false }
        return true
    }

    public var isSome: Bool {
        guard case .some = self else { return false }
        return true
    }

    public var empty: Void? {
        guard case .empty = self else { return nil }
        return ()
    }

    public var some: T? {
        guard case let .some(value) = self else { return nil }
        return value
    }
}
