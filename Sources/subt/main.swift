import Foundation
import RxSwift

let group = DispatchGroup()
group.enter()
group.notify(queue: DispatchQueue.main) {
    exit(EXIT_SUCCESS)
}

//import OpenSubtitlesDownloader
//_ = OpenSubtitleAPI
//    .search(
//        SearchParameters(
//            query: "game of thrones",
//            episode: 2,
//            season: 8,
//            language: .portugueseBrazil)
//    )
//    .run((URLSession.shared, UserAgent(rawValue: "TemporaryUserAgent")))
//    .flatMapCompletable {
//        OpenSubtitleAPI
//            .download($0.first!.zipDownloadLink)
//            .run((URLSession.shared, UserAgent(rawValue: "TemporaryUserAgent")))
//            .map {
//                let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//                try $0.write(to: paths[0].appendingPathComponent("bla.zip"), options: .withoutOverwriting)
//            }
//            .asCompletable()
//    }
//    .subscribe(onCompleted: {
//        group.leave()
//    }, onError: {
//        print("\($0)")
//        group.leave()
//    })

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

