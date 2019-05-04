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
