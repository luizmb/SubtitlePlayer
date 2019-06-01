#if os(watchOS)
import WatchKit

extension WKInterfaceController {
    public static var name: String {
        return String(
            NSStringFromClass(self)
                .split(separator: ".")
                .last!
                .dropLast("Controller".count)
        )
    }
}

public protocol Controller {
    func pushController(withName name: String, context: Any?)
    func pop()
    func popToRootController()
    func becomeCurrentPage()
    func presentController(withName name: String, context: Any?)
    func presentController(withNames names: [String], contexts: [Any]?)
    func dismiss()
    func presentTextInputController(withSuggestions suggestions: [String]?, allowedInputMode inputMode: WKTextInputMode, completion: @escaping ([Any]?) -> Void)
    func presentTextInputControllerWithSuggestions(forLanguage suggestionsHandler: ((String) -> [Any]?)?, allowedInputMode inputMode: WKTextInputMode, completion: @escaping ([Any]?) -> Void)
    func dismissTextInputController()
}

extension WKInterfaceController: Controller { }
#endif

#if os(iOS)
import UIKit
extension UIViewController {
    public static var name: String {
        return String(
            NSStringFromClass(self)
                .split(separator: ".")
                .last!
                .dropLast("Controller".count)
        )
    }
}

public protocol Controller {
//    func pushController(withName name: String, context: Any?)
//    func pop()
//    func popToRootController()
//    func becomeCurrentPage()
//    func presentController(withName name: String, context: Any?)
//    func presentController(withNames names: [String], contexts: [Any]?)
//    func dismiss()
//    func presentTextInputController(withSuggestions suggestions: [String]?, allowedInputMode inputMode: WKTextInputMode, completion: @escaping ([Any]?) -> Void)
//    func presentTextInputControllerWithSuggestions(forLanguage suggestionsHandler: ((String) -> [Any]?)?, allowedInputMode inputMode: WKTextInputMode, completion: @escaping ([Any]?) -> Void)
//    func dismissTextInputController()
}

extension UIViewController: Controller { }
#endif
