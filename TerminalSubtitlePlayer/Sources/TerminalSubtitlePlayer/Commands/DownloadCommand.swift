import ArgumentParser
import Combine
import Foundation
import FoundationExtensions
import SubtitleDownloader

struct DownloadCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "download",
        abstract: "Downloads a subtitle file from an URL"
    )

    @Option(help: "Subtitle URL from where the file will be downloaded.")
    var url: URL

    @Option(help: "Path to the folder where the downloaded file will be saved")
    var destination: String

    @Flag(help: "Play it immediately. Defaults to false.")
    var play: Bool = false

    @Flag(help: "Debugging printing. Defaults to false.")
    var debug: Bool = false

    @Option(help: "In case the subtitle should be played immediately, the encoding to use when reading its contents. Defaults to utf8.")
    var encoding: String.Encoding = .utf8

    func run() throws {
        OpenSubtitlesManager
            .download(from: url, unzipInto: destination)
            .mapValue { $0.mapError(identity) }
            .contramapEnvironment(\World.subtitleDownloaderDependencies)
            .flatMapPublisher { path -> Reader<World, AnyPublisher<Void, Error>> in
                play
                    ? ConsolePlayer
                        .play(path: path, encoding: encoding, from: 0, debug: debug)
                        .mapValue { $0.map { _ in }.mapError(identity).eraseToAnyPublisher() }
                        .contramapEnvironment(\World.fileRead)
                    : Reader { _ in Empty(completeImmediately: true).eraseToAnyPublisher() }
            }
            .inject(World.default)
            .sinkBlockingAndExit(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Done!")
                    case let .failure(error):
                        print("Oops:\n\(error)")
                    }
                },
                receiveValue: { _ in }
            )
    }
}
