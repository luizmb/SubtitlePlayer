import UIKit

public final class LocalStorageViewController: UIViewController {
    private var didAppearSignal: (() -> Void)!
    private var willDisappearSignal: (() -> Void)!
    private var plusTapSignal: (() -> Void)!
    private var editTapSignal: (() -> Void)!
    private let viewModel: ViewModel<LocalStorageViewModelInput, LocalStorageViewModelOutput>
    @IBOutlet private weak var table: UITableView!

    public init(viewModel: ViewModel<LocalStorageViewModelInput, LocalStorageViewModelOutput>) {
        self.viewModel = viewModel
        super.init(nibName: LocalStorageViewController.name, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()

        let outputs: LocalStorageViewModelOutput = (
            tableItems: { [weak self] itemList in
//                self?.table.setNumberOfRows(itemList.count, withRowType: LocalStorageRow.name)
//
//                itemList.enumerated().forEach { offset, itemOutput in
//                    (self?.table.rowController(at: offset) as? LocalStorageRow).map {
//                        $0.bind(itemOutput)
//                    }
//                }
//
//                self?.insertHeader()
            },
            editMode: { [weak self] editMode in
//                guard let strongSelf = self else { return }
//                (0 ..< strongSelf.table.numberOfRows)
//                    .compactMap { index in
//                        (strongSelf.table.rowController(at: index) as? LocalStorageRow)
//                            .map { (index, $0) }
//                    }
//                    .forEach { index, cell in
//                        self?.animate(withDuration: 0.4) {
//                            cell.editModeSignal(editMode, cell, index)
//                        }
//                }
            },
            scrollToRow: { [weak self] row in
                self?.table.scrollToRow(at: IndexPath(row: row, section: 0), at: .top, animated: true)
            },
            controller: self
        )

        let inputs = viewModel.bind(outputs)

        self.didAppearSignal = inputs.didAppear
        self.willDisappearSignal = inputs.willDisappear
        self.plusTapSignal = inputs.plusTap
        self.editTapSignal = inputs.editTap

        inputs.awakeWithContext()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didAppearSignal()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        willDisappearSignal()
    }

    private func insertHeader() {
//        table?.insertRows(at: IndexSet(integer: 0), withRowType: EditRow.name)
//        (table?.rowController(at: 0) as? EditRow).map {
//            $0.plusTapSignal = { [weak self] in self?.plusTapSignal() }
//            $0.editTapSignal = { [weak self] in self?.editTapSignal() }
//        }
    }
}

extension LocalStorageViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = (table.cellForRow(at: indexPath) as? LocalStorageRow),
            let signal = cell.itemSelectedSignal else { return }
        signal(cell, indexPath.row)
    }
}
