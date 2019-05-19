import WatchKit

public final class SearchResultRow: NSObject {
    public static let name = "SearchResultRow"
    @IBOutlet private weak var titleLabel: WKInterfaceLabel!
    @IBOutlet private weak var yearLabel: WKInterfaceLabel!
    @IBOutlet private weak var languageLabel: WKInterfaceLabel!
    @IBOutlet private weak var fileLabel: WKInterfaceLabel!
    var itemSelectedSignal: ((NSObject, Int) -> Void)!

    public func bind(_ model: (SearchResultItemViewModelOutput) -> SearchResultItemViewModelInput) {
        let inputs = model((
            title: { [weak self] text in self?.titleLabel.setText(text) },
            year: { [weak self] text in self?.yearLabel.setText(text) },
            language: { [weak self] text in self?.languageLabel.setText(text) },
            file: { [weak self] text in self?.fileLabel.setText(text) },
            background: { [weak self] state in
                switch state {
                case .remote:
                    self?.titleLabel.setTextColor(.gray)
                case .downloading:
                    self?.titleLabel.setTextColor(.yellow)
                case .local:
                    self?.titleLabel.setTextColor(.green)
                }
            }
        ))

        itemSelectedSignal = inputs
    }
}
