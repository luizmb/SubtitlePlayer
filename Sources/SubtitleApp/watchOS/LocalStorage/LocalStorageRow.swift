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
            title: { [weak self] text in self?.titleLabel.setText(text) },
            season: { [weak self] text in self?.seasonLabel.setText(text) },
            language: { [weak self] text in self?.languageLabel.setText(text) },
            file: { [weak self] text in self?.fileLabel.setText(text) }
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
