import WatchKit

public final class LocalStorageRow: NSObject {
    public static let name = "LocalStorageRow"

    @IBOutlet private weak var titleLabel: WKInterfaceLabel!
    @IBOutlet private weak var seasonLabel: WKInterfaceLabel!
    @IBOutlet private weak var fileLabel: WKInterfaceLabel!
    @IBOutlet private weak var containerGroup: WKInterfaceGroup!
    @IBOutlet private weak var deleteButton: WKInterfaceButton!

    @IBOutlet private weak var languageLabel: WKInterfaceLabel!
    var itemSelectedSignal: ((NSObject, Int) -> Void)!
    private var itemDeletedSignal: (() -> Void)?
    var editModeSignal: ((Bool, NSObject, Int) -> Void)!

    public func bind(_ model: (LocalStorageItemViewModelOutput) -> LocalStorageItemViewModelInput) {
        editMode(false)
        let inputs = model((
            title: titleLabel.setText,
            season: seasonLabel.setText,
            language: languageLabel.setText,
            file: fileLabel.setText
        ))

        itemSelectedSignal = inputs.itemSelected
        editModeSignal = { [weak self] enabled, sender, index in
            self?.editMode(enabled)
            self?.itemDeletedSignal = enabled ? { inputs.itemDeleted(sender, index) } : nil
        }
    }

    func editMode(_ enabled: Bool) {
        containerGroup.setRelativeWidth(1.0, withAdjustment: enabled ? -54 : 0)
        deleteButton.setHidden(!enabled)
    }

    @IBAction func deleteButtonTap() {
        itemDeletedSignal?()
    }
}
