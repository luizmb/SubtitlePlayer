import Foundation

public class InterfaceControllerContext: NSObject {
    let wrapped: Any

    public init(_ wrapped: Any) {
        self.wrapped = wrapped
    }

    public static func wrapped<ContextType>(context: Any?) -> ContextType? {
        return (context as? InterfaceControllerContext)?.wrapped as? ContextType
    }
}

extension ViewModel {
    public var asContext: InterfaceControllerContext {
        return InterfaceControllerContext(self)
    }
}
