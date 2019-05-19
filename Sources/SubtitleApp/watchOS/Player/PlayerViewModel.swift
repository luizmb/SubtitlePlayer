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
    forwardButtonTap: () -> Void,
    crownRotate: (Double) -> Void,
    crownRotationEnded: () -> Void
)

public typealias PlayerViewModelOutput = (
    subtitle: (String) -> Void,
    playingToggleText: (String) -> Void,
    rewindButtonHidden: (Bool) -> Void,
    forwardButtonHidden: (Bool) -> Void,
    hapticClick: () -> Void
)

public func playerViewModel(router: Router, subtitle: Subtitle) -> (PlayerViewModelOutput) -> PlayerViewModelInput {
    return { output in
        var disposeBag: DisposeBag? = DisposeBag()
        var playing = false
        var currentLine = 0
        var crownAccumulation: Double = 0

        return (
            awakeWithContext: { _ in output.subtitle("") },
            didAppear: {
                setPlaying(playing, output: output)
            },
            willDisappear: { },
            rewindButtonTap: {
                currentLine = max(currentLine - 1, 0)
                output.subtitle(subtitle.lines.first(where: { $0.sequence == currentLine }).map(^\.text) ?? "")
                output.hapticClick()
            },
            playToggleButtonTap: {
                playing.toggle()
                setPlaying(playing, output: output)

                if playing {
                    disposeBag = disposeBag ?? DisposeBag()
                    output.hapticClick()
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
                    output.hapticClick()
                    output.subtitle(subtitle.lines.first(where: { $0.sequence == currentLine }).map(^\.text) ?? "")
                }
            },
            forwardButtonTap: {
                currentLine = min(currentLine + 1, subtitle.lines.map(^\.sequence).max() ?? Int.max)
                output.subtitle(subtitle.lines.first(where: { $0.sequence == currentLine }).map(^\.text) ?? "")
                output.hapticClick()
            },
            crownRotate: { delta in
                guard !playing else { return }
                crownAccumulation += delta

                if crownAccumulation > 0.1 {
                    crownAccumulation = 0
                    let newLine = min(currentLine + 1, subtitle.lines.map(^\.sequence).max() ?? Int.max)
                    guard newLine != currentLine else { return }
                    currentLine = newLine
                    output.hapticClick()
                    output.subtitle(subtitle.lines.first(where: { $0.sequence == currentLine }).map(^\.text) ?? "")
                } else if crownAccumulation < -0.1 {
                    crownAccumulation = 0
                    let newLine = max(currentLine - 1, 0)
                    guard newLine != currentLine else { return }
                    currentLine = newLine
                    output.hapticClick()
                    output.subtitle(subtitle.lines.first(where: { $0.sequence == currentLine }).map(^\.text) ?? "")
                }
            },
            crownRotationEnded: {
                crownAccumulation = 0
            }
        )
    }
}

private func setPlaying(_ playing: Bool, output: PlayerViewModelOutput) {
    output.forwardButtonHidden(playing ? true : false)
    output.rewindButtonHidden(playing ? true : false)
    output.playingToggleText(playing ? "⏸" : "▶️")
}
