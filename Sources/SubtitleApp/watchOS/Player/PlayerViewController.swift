import WatchKit

public final class PlayerViewController: WKInterfaceController {
    @IBOutlet private weak var rewindButton: WKInterfaceButton!
    @IBOutlet private weak var playToggleButton: WKInterfaceButton!
    @IBOutlet private weak var forwardButton: WKInterfaceButton!
    @IBOutlet private weak var subtitleLabel: WKInterfaceLabel!

    private var didAppearSignal: (() -> Void)!
    private var willDisappearSignal: (() -> Void)!
    private var rewindButtonTapSignal: (() -> Void)!
    private var playToggleButtonTapSignal: (() -> Void)!
    private var forwardButtonTapSignal: (() -> Void)!
    private var crownRotateSignal: ((Double) -> Void)!

    public override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        crownSequencer.delegate = self
        crownSequencer.isHapticFeedbackEnabled = true

        let viewModel: ViewModel<PlayerViewModelInput, PlayerViewModelOutput>! = InterfaceControllerContext.wrapped(context: context)

        let outputs: PlayerViewModelOutput = (
            subtitle: { [weak self] text in self?.subtitleLabel.setText(text) },
            playingToggleText: { [weak self] text in self?.playToggleButton.setTitle(text) },
            rewindButtonHidden: { [weak self] hidden in self?.rewindButton.setHidden(hidden) },
            forwardButtonHidden: { [weak self] hidden in self?.forwardButton.setHidden(hidden) }
        )

        let inputs = viewModel.bind(outputs)

        self.didAppearSignal = inputs.didAppear
        self.willDisappearSignal = inputs.willDisappear
        self.rewindButtonTapSignal = inputs.rewindButtonTap
        self.playToggleButtonTapSignal = inputs.playToggleButtonTap
        self.forwardButtonTapSignal = inputs.forwardButtonTap
        self.crownRotateSignal = inputs.crownRotate

        inputs.awakeWithContext(context)
    }

    @IBAction func rewindButtonTap() {
        rewindButtonTapSignal()
    }

    @IBAction func playToggleButtonTap() {
        playToggleButtonTapSignal()
    }

    @IBAction func forwardButtonTap() {
        forwardButtonTapSignal()
    }

    public override func didAppear() {
        super.didAppear()
        crownSequencer.focus()
        didAppearSignal()
    }

    public override func willDisappear() {
        super.willDisappear()
        willDisappearSignal()
    }
}

extension PlayerViewController: WKCrownDelegate {
    public func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        crownRotateSignal(rotationalDelta)
    }
}
