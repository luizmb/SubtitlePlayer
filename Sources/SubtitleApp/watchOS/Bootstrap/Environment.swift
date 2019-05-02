import Common
import Foundation
import OpenSubtitlesDownloader

public struct Environment {
    public let now: () -> Date
    public let urlSession: () -> URLSessionProtocol
    public let openSubtitlesUserAgent: () -> UserAgent
    public let fileManager: () -> FileManagerProtocol
    public let gzip: () -> GzipProtocol.Type
}

extension Reader {
    public func contramap<E2>(
        _ first: @escaping (E2) -> () -> E)
        -> Reader<E2, A> {
            return contramap { first($0)() }
    }

    public func contramap<E2, First, Second>(
        _ first: @escaping (E2) -> () -> First,
        _ second: @escaping (E2) -> () -> Second)
        -> Reader<E2, A> where E == (First, Second) {
            return contramap { zip(zip(first, second)($0))() }
    }

    public func contramap<E2, First, Second, Third>(
        _ first: @escaping (E2) -> () -> First,
        _ second: @escaping (E2) -> () -> Second,
        _ third: @escaping (E2) -> () -> Third)
        -> Reader<E2, A> where E == (First, Second, Third) {
            return contramap { zip(zip(first, second, third)($0))() }
    }

    public func contramap<E2, First, Second, Third, Fourth>(
        _ first: @escaping (E2) -> () -> First,
        _ second: @escaping (E2) -> () -> Second,
        _ third: @escaping (E2) -> () -> Third,
        _ fourth: @escaping (E2) -> () -> Fourth)
        -> Reader<E2, A> where E == (First, Second, Third, Fourth) {
            return contramap { zip(zip(first, second, third, fourth)($0))() }
    }
}
