import WatchKit

public final class SearchResultViewController: WKInterfaceController {
    private var didAppearSignal: (() -> Void)!
    private var willDisappearSignal: (() -> Void)!

    public override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        let viewModel: ViewModel<SearchResultViewModelInput, SearchResultViewModelOutput>! = InterfaceControllerContext.wrapped(context: context)

        let outputs: SearchResultViewModelOutput = ()

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
