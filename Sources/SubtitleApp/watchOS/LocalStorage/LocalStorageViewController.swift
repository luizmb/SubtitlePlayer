import WatchKit

public final class LocalStorageViewController: WKInterfaceController {
    private var didAppearSignal: (() -> Void)!
    private var willDisappearSignal: (() -> Void)!
    private var plusTapSignal: (() -> Void)!
    private var editTapSignal: (() -> Void)!
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

                self?.insertHeader()
            },
            editMode: { [weak self] editMode in
                guard let strongSelf = self else { return }
                (0 ..< strongSelf.table.numberOfRows)
                    .compactMap { index in
                        (strongSelf.table.rowController(at: index) as? LocalStorageRow)
                            .map { (index, $0) }
                    }
                    .forEach { index, cell in
                        self?.animate(withDuration: 0.4) {
                            cell.editModeSignal(editMode, cell, index)
                        }
                    }
            },
            scrollToRow: table.scrollToRow(at:),
            controller: self
        )

        let inputs = viewModel.bind(outputs)

        self.didAppearSignal = inputs.didAppear
        self.willDisappearSignal = inputs.willDisappear
        self.plusTapSignal = inputs.plusTap
        self.editTapSignal = inputs.editTap

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

    private func insertHeader() {
        table?.insertRows(at: IndexSet(integer: 0), withRowType: EditRow.name)
        (table?.rowController(at: 0) as? EditRow).map {
            $0.plusTapSignal = { [weak self] in self?.plusTapSignal() }
            $0.editTapSignal = { [weak self] in self?.editTapSignal() }
        }
    }
}
