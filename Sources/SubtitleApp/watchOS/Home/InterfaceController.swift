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
