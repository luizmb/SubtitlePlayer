import Foundation
import OpenSubtitlesDownloader
import RxSwift

extension Environment {
    fileprivate static var current: Environment = Environment(
        now: Date.init,
        urlSession: { URLSession.shared },
        openSubtitlesUserAgent: { UserAgent(rawValue: "TemporaryUserAgent") },
        fileManager: FileManager.init,
        gzip: { Gzip.self }
    )
}

let group = DispatchGroup()
group.enter()
group.notify(queue: DispatchQueue.main) {
    exit(EXIT_SUCCESS)
}

_ = Command
    .parse(Array(CommandLine.arguments.dropFirst()))
    .asSingle
    .flatMapCompletable { $0.execute().inject(Environment.current) }
    .subscribe(
        onCompleted: group.leave,
        onError: { error in
            print("Main thing error: \(error)")
            group.leave()
        }
    )

dispatchMain()
