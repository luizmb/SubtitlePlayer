import WatchKit

public final class PlayerViewController: WKInterfaceController {
    @IBOutlet weak var subtitleLabel: WKInterfaceLabel!
    private var didAppearSignal: (() -> Void)!
    private var willDisappearSignal: (() -> Void)!

    public override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        let viewModel: ViewModel<PlayerViewModelInput, PlayerViewModelOutput>! = InterfaceControllerContext.wrapped(context: context)

        let outputs: PlayerViewModelOutput = (
            subtitle: subtitleLabel.setText,
            playing: { _ in }
        )

        let inputs = viewModel.bind(outputs)

        self.didAppearSignal = inputs.didAppear
        self.willDisappearSignal = inputs.willDisappear

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
}
