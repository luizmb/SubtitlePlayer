import WatchKit

public final class EditRow: NSObject {
    public static let name = "EditRow"
    @IBOutlet private weak var plusButton: WKInterfaceButton!
    @IBOutlet private weak var editButton: WKInterfaceButton!

    var plusTapSignal: (() -> Void)?
    var editTapSignal: (() -> Void)?

    @IBAction private func plusButtonTap() {
        plusTapSignal?()
    }

    @IBAction private func editButtonTap() {
        editTapSignal?()
    }
}
