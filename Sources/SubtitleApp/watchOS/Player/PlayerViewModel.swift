import Common
import Foundation
import RxSwift
import SubtitlePlayer

public typealias PlayerViewModelInput = (
    awakeWithContext: (Any?) -> Void,
    didAppear: () -> Void,
    willDisappear: () -> Void,
    rewindButtonTap: () -> Void,
    playToggleButtonTap: () -> Void,
    forwardButtonTap: () -> Void
)

public typealias PlayerViewModelOutput = (
    subtitle: (String) -> Void,
    playingToggleText: (String) -> Void,
    rewindButtonHidden: (Bool) -> Void,
    forwardButtonHidden: (Bool) -> Void
)

public func playerViewModel(router: Router, subtitle: Subtitle) -> (PlayerViewModelOutput) -> PlayerViewModelInput {
    return { output in
        var disposeBag: DisposeBag? = DisposeBag()
        var playing = false
        var currentLine = 0

        return (
            awakeWithContext: { _ in output.subtitle("") },
            didAppear: {
                setPlaying(playing, output: output)
            },
            willDisappear: { },
            rewindButtonTap: {
                currentLine = max(currentLine - 1, 0)
                output.subtitle(subtitle.lines.first(where: { $0.sequence == currentLine }).map(^\.text) ?? "")
            },
            playToggleButtonTap: {
                playing.toggle()
                setPlaying(playing, output: output)

                if playing {
                    disposeBag = disposeBag ?? DisposeBag()
                    currentLine = currentLine >= subtitle.lines.count ? 0 : currentLine
                    return SubtitlePlayer
                        .play(subtitle: subtitle, from: currentLine)
                        .subscribe(onNext: { lines in
                            DispatchQueue.main.async {
                                currentLine = lines.last?.sequence ?? currentLine
                                output.subtitle(lines.map(^\.text).joined(separator: "\n"))
                            }
                        }).disposed(by: disposeBag!)
                } else {
                    disposeBag = nil
                    output.subtitle(subtitle.lines.first(where: { $0.sequence == currentLine }).map(^\.text) ?? "")
                }
            },
            forwardButtonTap: {
                currentLine = min(currentLine + 1, subtitle.lines.map(^\.sequence).max() ?? Int.max)
                output.subtitle(subtitle.lines.first(where: { $0.sequence == currentLine }).map(^\.text) ?? "")
            }
        )
    }
}

private func setPlaying(_ playing: Bool, output: PlayerViewModelOutput) {
    output.forwardButtonHidden(playing ? true : false)
    output.rewindButtonHidden(playing ? true : false)
    output.playingToggleText(playing ? "⏸" : "▶️")
}
