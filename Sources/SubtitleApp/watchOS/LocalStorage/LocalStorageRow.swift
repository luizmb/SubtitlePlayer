import WatchKit

public final class LocalStorageRow: NSObject {
    public static let name = "LocalStorageRow"

    @IBOutlet private weak var titleLabel: WKInterfaceLabel!
    @IBOutlet private weak var seasonLabel: WKInterfaceLabel!
    @IBOutlet private weak var fileLabel: WKInterfaceLabel!

    @IBOutlet weak var languageLabel: WKInterfaceLabel!
    var itemSelectedSignal: ((NSObject, Int) -> Void)!

    public func bind(_ model: (LocalStorageItemViewModelOutput) -> LocalStorageItemViewModelInput) {
        let inputs = model((
            title: titleLabel.setText,
            season: seasonLabel.setText,
            language: languageLabel.setText,
            file: fileLabel.setText
        ))

        itemSelectedSignal = inputs.itemSelected
    }
}
