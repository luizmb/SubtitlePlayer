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
            title: titleLabel.setText,
            year: yearLabel.setText,
            language: languageLabel.setText,
            file: fileLabel.setText,
            isDownloaded: { [weak self] downloaded in self?.titleLabel.setTextColor(downloaded ? .green : .red) },
            isDownloading: { [weak self] downloading in self?.fileLabel.setTextColor(downloading ? .green : .red) }
        ))

        itemSelectedSignal = inputs
    }
}
