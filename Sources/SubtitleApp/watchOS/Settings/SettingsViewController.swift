import WatchKit

public final class SettingsViewController: WKInterfaceController {
    @IBOutlet private weak var encodingLabel: WKInterfaceLabel!

    private var didAppearSignal: (() -> Void)!
    private var willDisappearSignal: (() -> Void)!
    private var encodingButtonTapSignal: ((Controller) -> Void)!

    public override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        let viewModel: ViewModel<SettingsViewModelInput, SettingsViewModelOutput>! = InterfaceControllerContext.wrapped(context: context)

        let outputs: SettingsViewModelOutput = (
            encodingLabelString: { [weak self] text in
                self?.encodingLabel.setText(text)
            },
            _: ()
        )

        let inputs = viewModel.bind(outputs)

        self.didAppearSignal = inputs.didAppear
        self.willDisappearSignal = inputs.willDisappear
        self.encodingButtonTapSignal = inputs.encodingButtonTap

        inputs.awakeWithContext(context)
    }

    public override func didAppear() {
        super.didAppear()
        didAppearSignal()
    }

    public override func willDisappear() {
        super.willDisappear()
        willDisappearSignal()
    }
    @IBAction private func setEncodingButtonTap() {
        encodingButtonTapSignal(self)
    }
}
