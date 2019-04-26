import Foundation

prefix operator ^
prefix func ^ <Root, Value>(keyPath: KeyPath<Root, Value>) -> (Root) -> Value {
    return { root in
        root[keyPath: keyPath]
    }
}
