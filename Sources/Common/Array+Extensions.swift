import Foundation

extension Array {
    public subscript (safe index: Int) -> Element? {
        get {
            return inBounds(index) ? self[index] : nil
        }
        set {
            guard inBounds(index), let newValue = newValue else { return }
            self[index] = newValue
        }
    }

    @discardableResult
    public mutating func removeSafe(at index: Int) -> Element? {
        guard let item = self[safe: index] else { return nil }
        remove(at: index)
        return item
    }

    private func inBounds(_ index: Int) -> Bool {
        return index < count && index >= 0
    }

    public func firstNonNil<A>(_ lens: (Element) -> A?) -> A? {
        return first(where: { lens($0) != nil }).flatMap(lens)
    }
}
