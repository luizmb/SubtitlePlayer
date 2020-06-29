import ArgumentParser
import Combine
import Foundation
import FoundationExtensions
import SubtitleDownloader

struct SearchCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "search",
        abstract: "Searches for subtitles on OpenSubtitles.org"
    )

    @Option(help: "Search query term. Usually the name of your movie or series.")
    var query: String

    @Option(help: "In case of series, which season. Empty if want to show any season or it's a movie.")
    var season: Int?

    @Option(help: "In case of series, which episode. Empty if want to show any episode or it's a movie.")
    var episode: Int?

    @Option(help: "Search for tag")
    var tag: String?

    @Option(help: "Movie or episode Id on IMDB")
    var imdb: ImdbId?

    @Option(help: "Language ID as defined in http://www.opensubtitles.org/addons/export_languages.php")
    var language: LanguageId?

    @Option(help: "Expected byte size")
    var byteSize: Int?

    @Option(help: "Expected hash")
    var hash: String?

    func run() throws {
        searchOnly(parameters: searchParameters)
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

    var searchParameters: SearchParameters {
        SearchParameters(
            imdb: imdb,
            movieInfo: zip(
                byteSize,
                hash
            ).flatMap(MovieInfo.init),
            query: query,
            episode: episode,
            season: season,
            language: language ?? .all,
            tag: tag
        )
    }
}

private func searchOnly(parameters: SearchParameters) -> Reader<World, AnyPublisher<Void, NetworkError>> {
    OpenSubtitlesManager
        .search(parameters)
        .mapValue { searchPromise -> AnyPublisher<Void, NetworkError> in
            searchPromise
                .handleEvents(receiveOutput: printSearchResult)
                .map { _ in }
                .eraseToAnyPublisher()
        }.contramapEnvironment(\World.subtitleDownloaderDependencies.networking)
}

private func printSearchResult(searchResult: [SearchResponse]) {
    print(
        searchResult
            .map {
                """
                Title:   \t\($0.movieName) \($0.formattedSeriesString.map { "(\($0))" } ?? "")
                Year:    \t\($0.movieYear)
                Language:\t\($0.languageName)
                Score:   \t\($0.score)
                ID:      \t\($0.idSubtitleFile)
                File:    \t\($0.subFileName)
                Link:    \t\($0.subDownloadLink)

                """
            }.joined(separator: "\n")
    )
}
