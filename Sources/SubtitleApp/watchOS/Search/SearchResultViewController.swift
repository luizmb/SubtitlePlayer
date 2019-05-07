import RxSwift
import WatchKit

public final class SearchResultViewController: WKInterfaceController {
    private var didAppearSignal: (() -> Void)!
    private var willDisappearSignal: (() -> Void)!
    private let disposeBag = DisposeBag()
    @IBOutlet private weak var table: WKInterfaceTable!

    public override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        let viewModel: ViewModel<SearchResultViewModelInput, SearchResultViewModelOutput>! = InterfaceControllerContext.wrapped(context: context)

        let outputs: SearchResultViewModelOutput = (
            disposeBag: disposeBag,
            items: { [weak self] itemList in
                self?.table.setNumberOfRows(itemList.count, withRowType: SearchResultRow.name)
                itemList.enumerated().forEach { offset, itemOutput in
                    (self?.table.rowController(at: offset) as? SearchResultRow).map {
                        $0.bind(itemOutput)
                    }
                }
            }
        )

        let inputs = viewModel.bind(outputs)

        self.didAppearSignal = inputs.didAppear
        self.willDisappearSignal = inputs.willDisappear

        inputs.awakeWithContext(context)
    }

    public override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        guard let cell = (table.rowController(at: rowIndex) as? SearchResultRow),
            let signal = cell.itemSelectedSignal else { return }
        signal(cell, rowIndex)
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
