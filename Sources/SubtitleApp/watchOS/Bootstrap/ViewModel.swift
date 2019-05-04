import Foundation

public struct ViewModel<Input, Output> {
    let bind: (Output) -> Input
}

extension ViewModel {
    public var asContext: InterfaceControllerContext {
        return InterfaceControllerContext(self)
    }
}
