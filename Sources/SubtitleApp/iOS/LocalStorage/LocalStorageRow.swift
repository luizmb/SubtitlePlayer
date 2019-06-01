import UIKit

public final class LocalStorageRow: UITableViewCell {
    public static let name = "LocalStorageRow"

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var seasonLabel: UILabel!
    @IBOutlet private weak var fileLabel: UILabel!
    @IBOutlet private weak var languageLabel: UILabel!

    var itemSelectedSignal: ((NSObject, Int) -> Void)!

    public func bind(_ model: (LocalStorageItemViewModelOutput) -> LocalStorageItemViewModelInput) {
        let inputs = model((
            title: { [weak self] text in self?.titleLabel.text = text },
            season: { [weak self] text in self?.seasonLabel.text = text },
            language: { [weak self] text in self?.languageLabel.text = text },
            file: { [weak self] text in self?.fileLabel.text = text }
        ))

        itemSelectedSignal = inputs.itemSelected
    }
}
