import WatchKit

public final class SearchViewController: WKInterfaceController {
    @IBOutlet private weak var searchButton: WKInterfaceButton!
    @IBOutlet private weak var queryLabel: WKInterfaceLabel!
    @IBOutlet private weak var seasonLabel: WKInterfaceLabel!
    @IBOutlet private weak var episodeLabel: WKInterfaceLabel!
    @IBOutlet private weak var languageLabel: WKInterfaceLabel!

    private var didAppearSignal: (() -> Void)!
    private var willDisappearSignal: (() -> Void)!
    private var searchButtonTapSignal: ((Controller) -> Void)!
    private var queryButtonTapSignal: ((Controller) -> Void)!
    private var seasonButtonTapSignal: ((Controller) -> Void)!
    private var episodeButtonTapSignal: ((Controller) -> Void)!
    private var languageButtonTapSignal: ((Controller) -> Void)!

    public override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        let viewModel: ViewModel<SearchViewModelInput, SearchViewModelOutput>! = InterfaceControllerContext.wrapped(context: context)

        let outputs: SearchViewModelOutput = (
            queryLabelString: { [weak self] text in
                self?.queryLabel.setText(text)
            },
            seasonLabelString: { [weak self] text in
                self?.seasonLabel.setText(text)
            },
            episodeLabelString: { [weak self] text in
                self?.episodeLabel.setText(text)
            },
            languageLabelString: { [weak self] text in
                self?.languageLabel.setText(text)
            },
            searchButtonEnabled: { [weak self] enabled in
                self?.searchButton.setEnabled(enabled)
            }
        )

        let inputs = viewModel.bind(outputs)

        self.didAppearSignal = inputs.didAppear
        self.willDisappearSignal = inputs.willDisappear
        self.searchButtonTapSignal = inputs.searchButtonTap
        self.queryButtonTapSignal = inputs.queryButtonTap
        self.seasonButtonTapSignal = inputs.seasonButtonTap
        self.episodeButtonTapSignal = inputs.episodeButtonTap
        self.languageButtonTapSignal = inputs.languageButtonTap

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

    @IBAction private func searchButtonTap() {
        searchButtonTapSignal(self)
    }

    @IBAction private func setQueryButtonTap() {
        queryButtonTapSignal(self)
    }

    @IBAction private func setSeasonButtonTap() {
        seasonButtonTapSignal(self)
    }

    @IBAction private func setEpisodeButtonTap() {
        episodeButtonTapSignal(self)
    }

    @IBAction private func setLanguageButtonTap() {
        languageButtonTapSignal(self)
    }
}
