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

private struct PlayingDetails {
    let triggerStart: DispatchWallTime
    let offset: OffsetType

    enum OffsetType {
        // case time(DispatchTimeInterval)
        case lines(Int)
    }
}

public func playerViewModel(router: Router, subtitle: Subtitle) -> (PlayerViewModelOutput) -> PlayerViewModelInput {
    return { output in
        var disposableExecution: Disposable? = nil
        var playingDetails: PlayingDetails?
        var currentLine = 0
        var crownAccumulation: Double = 0
        let lastLine = subtitle.lastSequence

        return (
            awakeWithContext: { _ in output.subtitle("") },
            didAppear: {
                setPlaying(playingDetails != nil, output: output)
                output.progress(Double(currentLine) / Double(max(lastLine, 1)))
            },
            willDisappear: { },
            didDeactivate: {
                disposableExecution?.dispose()
                disposableExecution = nil
            },
            willActivate: {
                let now = DispatchWallTime.now()
                setPlaying(playingDetails != nil, output: output)
                output.subtitle("")
                guard let playingDetails = playingDetails, case let .lines(startingLine) = playingDetails.offset else { return }
                disposableExecution = SubtitlePlayer
                    .play(subtitle: subtitle, triggerTime: playingDetails.triggerStart, startingLine: startingLine, now: now)
                    .subscribe(onNext: { lines in
                        DispatchQueue.main.async {
                            currentLine = lines.last?.sequence ?? currentLine
                            output.progress(Double(currentLine) / Double(max(lastLine, 1)))
                            output.subtitle(lines.map(^\.text).joined(separator: "\n"))
                        }
                    })
            },
            rewindButtonTap: {
                currentLine = max(currentLine - 1, 0)
                output.subtitle(subtitle.line(sequence: currentLine)?.text ?? "")
                output.progress(Double(currentLine) / Double(max(lastLine, 1)))
                output.hapticClick()
            },
            playToggleButtonTap: {
                let now = DispatchWallTime.now()
                playingDetails = playingDetails != nil ? nil : PlayingDetails(triggerStart: now, offset: .lines(currentLine))
                setPlaying(playingDetails != nil, output: output)

                if playingDetails != nil {
                    currentLine = currentLine > lastLine ? 0 : currentLine
                    output.progress(Double(currentLine) / Double(max(lastLine, 1)))
                    disposableExecution = SubtitlePlayer
                        .play(subtitle: subtitle, triggerTime: now, startingLine: currentLine, now: now)
                        .subscribe(onNext: { lines in
                            DispatchQueue.main.async {
                                currentLine = lines.last?.sequence ?? currentLine
                                output.progress(Double(currentLine) / Double(max(lastLine, 1)))
                                output.subtitle(lines.map(^\.text).joined(separator: "\n"))
                            }
                        })
                } else {
                    disposableExecution?.dispose()
                    disposableExecution = nil
                    output.subtitle(subtitle.line(sequence: currentLine)?.text ?? "")
                }
                output.hapticClick()
            },
            forwardButtonTap: {
                currentLine = min(currentLine + 1, lastLine)
                output.progress(Double(currentLine) / Double(max(lastLine, 1)))
                output.subtitle(subtitle.line(sequence: currentLine)?.text ?? "")
                output.hapticClick()
            },
            crownRotate: { delta in
                guard playingDetails == nil else { return }
                crownAccumulation += delta

                if crownAccumulation > 0.1 {
                    crownAccumulation = 0
                    let newLine = min(currentLine + 1, lastLine)
                    guard newLine != currentLine else { return }
                    currentLine = newLine
                    output.progress(Double(currentLine) / Double(max(lastLine, 1)))
                    output.subtitle(subtitle.line(sequence: currentLine)?.text ?? "")
                    output.hapticClick()
                } else if crownAccumulation < -0.1 {
                    crownAccumulation = 0
                    let newLine = max(currentLine - 1, 0)
                    guard newLine != currentLine else { return }
                    currentLine = newLine
                    output.progress(Double(currentLine) / Double(max(lastLine, 1)))
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
