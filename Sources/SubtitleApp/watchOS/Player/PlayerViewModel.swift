import Common
import Foundation
import RxSwift
import SubtitlePlayer

public typealias PlayerViewModelInput = (
    awakeWithContext: (Any?) -> Void,
    didAppear: () -> Void,
    willDisappear: () -> Void
)

public typealias PlayerViewModelOutput = (
    subtitle: (String) -> Void,
    playing: (Bool) -> Void
)

public func playerViewModel(router: Router, subtitle: Subtitle) -> (PlayerViewModelOutput) -> PlayerViewModelInput {
    return { output in
        let disposeBag = DisposeBag()
        return (
            awakeWithContext: { _ in output.subtitle("") },
            didAppear: {
                SubtitlePlayer
                    .play(subtitle: subtitle)
                    .subscribe(onNext: { lines in
                        DispatchQueue.main.async {
                            output.subtitle(lines.map(^\.text).joined(separator: "\n"))
                        }
                    }).disposed(by: disposeBag)
            },
            willDisappear: { }
        )
    }
}
