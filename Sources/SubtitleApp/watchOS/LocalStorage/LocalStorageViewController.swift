import WatchKit

public final class LocalStorageViewController: WKInterfaceController {
    private var didAppearSignal: (() -> Void)!
    private var willDisappearSignal: (() -> Void)!
    @IBOutlet private weak var table: WKInterfaceTable!

    public override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        let viewModel: ViewModel<LocalStorageViewModelInput, LocalStorageViewModelOutput>! = InterfaceControllerContext.wrapped(context: context)

        let outputs: LocalStorageViewModelOutput = (
            tableItems: { [weak self] itemList in
                self?.table.setNumberOfRows(itemList.count, withRowType: LocalStorageRow.name)
                itemList.enumerated().forEach { offset, itemOutput in
                    (self?.table.rowController(at: offset) as? LocalStorageRow).map {
                        $0.bind(itemOutput)
                    }
                }
            },
            scrollToRow: table.scrollToRow(at:),
            controller: self
        )

        let inputs = viewModel.bind(outputs)

        self.didAppearSignal = inputs.didAppear
        self.willDisappearSignal = inputs.willDisappear

        inputs.awakeWithContext(context)
    }

    public override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        guard let cell = (table.rowController(at: rowIndex) as? LocalStorageRow),
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
