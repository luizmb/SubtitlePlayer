import Common
import Foundation
import RxSwift
import SubtitlePlayer

public typealias PlayerViewModelInput = (
    awakeWithContext: (Any?) -> Void,
    didAppear: () -> Void,
    willDisappear: () -> Void,
    didDeactivate: () -> Void,
    willActivate: () -> Void,
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
    progress: (Double) -> Void,
    hapticClick: () -> Void
)

private struct PlayingDetails: Equatable {
    let triggerStart: Date
    let startingLine: Int
}

public func playerViewModel(router: Router, subtitle: Subtitle) -> (PlayerViewModelOutput) -> PlayerViewModelInput {
    return { output in
        var disposableExecution: Disposable? = nil
        var playingDetails: PlayingDetails? {
            didSet {
                guard playingDetails != oldValue else { return }
                setPlaying(playingDetails != nil, output: output)
            }
        }
        let lastLine = subtitle.lastSequence
        var currentLine = -1 {
            didSet {
                guard currentLine != oldValue else { return }
                output.progress(progress(currentLine, lastLine))
                if currentLine == -1 {
                    playingDetails = nil
                }
            }
        }
        var crownAccumulation: Double = 0

        return (
            awakeWithContext: { _ in output.subtitle("") },
            didAppear: {
                currentLine = 0
                playingDetails = nil
            },
            willDisappear: { },
            didDeactivate: {
                disposableExecution?.dispose()
                disposableExecution = nil
            },
            willActivate: {
                let now = Date()
                output.subtitle("")
                guard let playingDetails = playingDetails else { return }
                disposableExecution = play(subtitle, playingDetails: playingDetails, now: now) {
                    currentLine = $0 ?? currentLine
                    output.subtitle($1)
                }
            },
            rewindButtonTap: {
                currentLine = max(currentLine - 1, 0)
                output.subtitle(subtitle.line(sequence: currentLine)?.text ?? "")
                output.hapticClick()
            },
            playToggleButtonTap: {
                let now = Date()
                currentLine = currentLine > lastLine ? 0 : currentLine

                if playingDetails == nil {
                    playingDetails = PlayingDetails(triggerStart: now, startingLine: currentLine)
                    disposableExecution = play(subtitle, playingDetails: playingDetails!, now: now){
                        currentLine = $0 ?? currentLine
                        output.subtitle($1)
                    }
                } else {
                    playingDetails = nil
                    disposableExecution?.dispose()
                    disposableExecution = nil
                    output.subtitle(subtitle.line(sequence: currentLine)?.text ?? "")
                }
                output.hapticClick()
            },
            forwardButtonTap: {
                currentLine = min(currentLine + 1, lastLine)
                output.subtitle(subtitle.line(sequence: currentLine)?.text ?? "")
                output.hapticClick()
            },
            crownRotate: {
                crownRotate(isPlaying: playingDetails != nil,
                            delta: $0,
                            accumulation: &crownAccumulation,
                            currentLine: currentLine,
                            lastLine: lastLine) {
                                currentLine = $0
                                output.subtitle(subtitle.line(sequence: currentLine)?.text ?? "")
                                output.hapticClick()
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

private func progress(_ current: Int, _ total: Int) -> Double {
    return Double(max(current, 0)) / Double(max(total, 1))
}

private func play(_ subtitle: Subtitle, playingDetails: PlayingDetails, now: Date, next: @escaping (Int?, String) -> Void) -> Disposable {
    return SubtitlePlayer
        .play(subtitle: subtitle,
              triggerTime: playingDetails.triggerStart,
              startingLine: playingDetails.startingLine,
              now: now)
        .subscribe(
            onNext: { lines in
                DispatchQueue.main.async {
                    let text = lines.map(^\.text).joined(separator: "\n")
                    next(lines.last?.sequence, text)
                }
            },
            onCompleted: {
                DispatchQueue.main.async {
                    next(-1, "")
                }
            }
        )
}

private func crownRotate(
    isPlaying: Bool,
    delta: Double,
    accumulation: inout Double,
    currentLine: Int,
    lastLine: Int,
    updateCurrentLine: @escaping (Int) -> Void) {
    guard !isPlaying else { return }
    let threshold = 0.1
    accumulation += delta
    guard abs(accumulation) > threshold else { return }

    let newLine = accumulation > 0
        ? min(currentLine + 1, lastLine)
        : max(currentLine - 1, 0)

    accumulation = 0
    guard newLine != currentLine else { return }
    updateCurrentLine(newLine)
}
