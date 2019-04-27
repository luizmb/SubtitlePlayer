import Foundation
import OpenSubtitlesDownloader
import RxSwift

extension Environment {
    fileprivate static var current: Environment = Environment(
        now: Date.init,
        urlSession: { URLSession.shared },
        openSubtitlesUserAgent: { UserAgent(rawValue: "TemporaryUserAgent") },
        fileManager: FileManager.init
    )
}

let group = DispatchGroup()
group.enter()
group.notify(queue: DispatchQueue.main) {
    exit(EXIT_SUCCESS)
}

_ = Command
    .parse(Array(CommandLine.arguments.dropFirst()))
    .flatMap { $0.execute().inject(Environment.current) }
    .subscribe(
        onError: {
            print("Error: \($0)")
            group.leave()
        }, onCompleted: {
            group.leave()
        }
    )

dispatchMain()
