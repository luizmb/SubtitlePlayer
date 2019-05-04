import WatchKit

public final class SearchViewController: WKInterfaceController {
    @IBOutlet private weak var searchButton: WKInterfaceButton!
    @IBOutlet private weak var queryLabel: WKInterfaceLabel!
    @IBOutlet private weak var seasonLabel: WKInterfaceLabel!
    @IBOutlet private weak var episodeLabel: WKInterfaceLabel!
    @IBOutlet private weak var languageLabel: WKInterfaceLabel!

    private var didAppearSignal: (() -> Void)!
    private var willDisappearSignal: (() -> Void)!
    private var searchButtonTapSignal: (() -> Void)!
    private var queryButtonTapSignal: (() -> Void)!
    private var seasonButtonTapSignal: (() -> Void)!
    private var episodeButtonTapSignal: (() -> Void)!
    private var languageButtonTapSignal: (() -> Void)!
    private var queryTextChangedSignal: ((String?) -> Void)!

    public override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        let viewModel: ViewModel<SearchViewModelInput, SearchViewModelOutput>! = InterfaceControllerContext.wrapped(context: context)

        let outputs: SearchViewModelOutput = (
            presentQueryDictation: { [weak self] suggestions in
                self?.presentTextInputController(withSuggestions: suggestions, allowedInputMode: .plain) { [weak self] text in
                    self?.queryTextChangedSignal(text?.first as? String)
                }
            },
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
        self.queryTextChangedSignal = inputs.queryTextChanged

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
        searchButtonTapSignal()
    }

    @IBAction private func setQueryButtonTap() {
        queryButtonTapSignal()
    }

    @IBAction private func setSeasonButtonTap() {
        seasonButtonTapSignal()
    }

    @IBAction private func setEpisodeButtonTap() {
        episodeButtonTapSignal()
    }

    @IBAction private func setLanguageButtonTap() {
        languageButtonTapSignal()
    }
}
