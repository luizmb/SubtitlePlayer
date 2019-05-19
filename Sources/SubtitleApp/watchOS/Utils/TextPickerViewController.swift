import WatchKit

public final class TextPickerViewController: WKInterfaceController {
    @IBOutlet private weak var picker: WKInterfacePicker!
    private var didAppearSignal: (() -> Void)!
    private var willDisappearSignal: (() -> Void)!
    private var indexSelectedSignal: ((Int) -> Void)!

    public override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        setTitle("Done")
        let viewModel: ViewModel<TextPickerViewModelInput, TextPickerViewModelOutput>! = InterfaceControllerContext.wrapped(context: context)

        let outputs: TextPickerViewModelOutput = (
            suggestions: { [weak self] suggestions in
                self?.picker.setItems(suggestions.map {
                    let item = WKPickerItem()
                    item.title = $0
                    return item
                })
            }, selectItem: { [weak self] index in
                self?.picker.setSelectedItemIndex(index)
            }
        )

        let inputs = viewModel.bind(outputs)

        self.didAppearSignal = inputs.didAppear
        self.willDisappearSignal = inputs.willDisappear
        self.indexSelectedSignal = inputs.indexSelected

        inputs.awakeWithContext(context)
    }

    public override func didAppear() {
        super.didAppear()
        picker.focus()
        didAppearSignal()
    }

    public override func willDisappear() {
        super.willDisappear()
        willDisappearSignal()
    }

    @IBAction private func textPickerDidChange(_ value: Int) {
        indexSelectedSignal(value)
    }
}
