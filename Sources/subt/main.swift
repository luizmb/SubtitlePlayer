import Foundation
import RxSwift

let group = DispatchGroup()
group.enter()
group.notify(queue: DispatchQueue.main) {
    exit(EXIT_SUCCESS)
}

/*
file=/Volumes/SeagateHybric2T/Downloads/Subtitles/Game.Of.Thrones.S08E02.540p.WEB.srt
file=/Volumes/SeagateHybric2T/Downloads/Subtitles/game.of.thrones.s08e02.720p.web.h264-memento.srt
file=/Volumes/SeagateHybric2T/Downloads/Subtitles/Game.of.Thrones.S08E02.1080p.AMZN.WEB-DL.DDP5.1.H.264-GoT.srt
file=/Volumes/SeagateHybric2T/Downloads/Subtitles/Game.of.Thrones.S08E02.1080p.WEB.x264-ADRENALiNE.srt
*/

_ = Command
    .parse(Array(CommandLine.arguments.dropFirst()))
    .flatMap { $0.execute() }
    .subscribe(
        onError: {
            print("Error: \($0)")
            group.leave()
        }, onCompleted: {
            group.leave()
        }
    )


dispatchMain()

