import Foundation

public struct ViewModel<Input, Output> {
    let bind: (Output) -> Input
}

#if os(iOS)
public typealias AwakeWithContentClosure = () -> Void
#elseif os(watchOS)
public typealias AwakeWithContentClosure = (Any?) -> Void
#endif
