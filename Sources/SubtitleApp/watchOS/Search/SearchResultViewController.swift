import RxSwift
import WatchKit

public final class SearchResultViewController: WKInterfaceController {
    private var didAppearSignal: (() -> Void)!
    private var willDisappearSignal: (() -> Void)!
    private let disposeBag = DisposeBag()
    private var itemSelectedSignal: ((InterfaceControllerProtocol, Int) -> Void)!
    @IBOutlet private weak var table: WKInterfaceTable!

    public override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        let viewModel: ViewModel<SearchResultViewModelInput, SearchResultViewModelOutput>! = InterfaceControllerContext.wrapped(context: context)

        let outputs: SearchResultViewModelOutput = (
            disposeBag: disposeBag,
            items: { [weak self] itemList in
                self?.table.setNumberOfRows(itemList.count, withRowType: SearchResultRow.name)
                itemList.enumerated().forEach { offset, item in
                    (self?.table.rowController(at: offset) as? SearchResultRow).map {
                        $0.titleLabel.setText(item.title)
                        $0.yearLabel.setText(item.year)
                        $0.languageLabel.setText(item.language)
                        $0.fileLabel.setText(item.file)
                    }
                }
            }
        )

        let inputs = viewModel.bind(outputs)

        self.didAppearSignal = inputs.didAppear
        self.willDisappearSignal = inputs.willDisappear
        self.itemSelectedSignal = inputs.itemSelected

        inputs.awakeWithContext(context)
    }

    public override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        itemSelectedSignal(self, rowIndex)
    }

    public override func didAppear() {
        super.didAppear()
        didAppearSignal()
    }

    public override func willDisappear() {
        super.willDisappear()
        willDisappearSignal()
    }
}

public final class SearchResultRow: NSObject {
    public static let name = "SearchResultRow"
    @IBOutlet fileprivate weak var titleLabel: WKInterfaceLabel!
    @IBOutlet fileprivate weak var yearLabel: WKInterfaceLabel!
    @IBOutlet fileprivate weak var languageLabel: WKInterfaceLabel!
    @IBOutlet fileprivate weak var fileLabel: WKInterfaceLabel!
}
