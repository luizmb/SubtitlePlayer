import WatchKit

public final class PlayerViewController: WKInterfaceController {
    private var didAppearSignal: (() -> Void)!
    private var willDisappearSignal: (() -> Void)!

    public override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        let viewModel: ViewModel<PlayerViewModelInput, PlayerViewModelOutput>! = InterfaceControllerContext.wrapped(context: context)

        let outputs: PlayerViewModelOutput = ()

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

/*
import Common
import OpenSubtitlesDownloader
import RxSwift
import SubtitlePlayer
import WatchKit

class InterfaceController: WKInterfaceController {
    @IBOutlet weak var subtitleLabel: WKInterfaceLabel!
    var bag = DisposeBag()

    override func didAppear() {
        OpenSubtitlesManager
            .searchDownloadUnzip(.init(query: "it crowd", episode: 3, season: 4, language: .english), at: 0)
            .contramap(^\.urlSession, ^\.openSubtitlesUserAgent, ^\.fileManager, ^\.gzip)
            .map {
                $0.asObservable().flatMap { data in
                    SubtitlePlayer
                        .play(data: data, encoding: .utf8, from: 1)
                }
            }.inject(Environment.current)
            .subscribe(onNext: { [weak self] (lines: [Subtitle.Line]) in
                DispatchQueue.main.async {
                    self?.subtitleLabel.setText(lines.map(^\.text).joined(separator: "\n"))
                }
            })
            .disposed(by: bag)
    }
}

extension Environment {
    fileprivate static var current: Environment = Environment(
        now: Date.init,
        urlSession: { URLSession.shared },
        openSubtitlesUserAgent: { UserAgent(rawValue: "TemporaryUserAgent") },
        fileManager: FileManager.init,
        gzip: { Gzip.self }
    )
}
*/
