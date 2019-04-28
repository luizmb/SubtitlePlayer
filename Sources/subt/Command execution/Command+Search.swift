import Common
import Foundation
import OpenSubtitlesDownloader
import RxSwift
import SubtitlePlayer

extension Command {
    static func search(with arguments: [SearchArgument]) -> Reader<Environment, Completable> {
        let searchParameters = SearchParameters(
            imdb: arguments.firstNonNil(^\.imdb),
            movieInfo: zip(
                arguments.firstNonNil(^\.byteSize),
                arguments.firstNonNil(^\.hash)
            ).flatMap(MovieInfo.init),
            query: arguments.firstNonNil(^\.query),
            episode: arguments.firstNonNil(^\.episode),
            season: arguments.firstNonNil(^\.season),
            language: arguments.firstNonNil(^\.language) ?? .all,
            tag: arguments.firstNonNil(^\.tag)
        )

        let initialLine = arguments.firstNonNil(^\.line) ?? 0

        return arguments
            .firstNonNil(^\.play)
            .fold(
                ifSome: { searchAndPlay(parameters: searchParameters, resultIndex: $0, sequence: initialLine) },
                ifNone: { searchOnly(parameters: searchParameters) }
            )
    }

    static func searchOnly(parameters: SearchParameters) -> Reader<Environment, Completable> {
        return OpenSubtitlesManager.search(parameters).map { searchPromise in
            searchPromise.do(onSuccess: printSearchResult).asCompletable()
        }.contramap { (urlSession: $0.urlSession(), userAgent: $0.openSubtitlesUserAgent()) }
    }

    static func searchAndPlay(parameters: SearchParameters, resultIndex: Int, encoding: String.Encoding = .isoLatin1, sequence: Int = 0) -> Reader<Environment, Completable> {
        let dependenciesResolver = { (env: Environment) in
            (urlSession: env.urlSession(), userAgent: env.openSubtitlesUserAgent(), fileManager: env.fileManager(), gzip: env.gzip())
        }

        return OpenSubtitlesManager
            .searchDownloadUnzip(parameters, at: resultIndex)
            .contramap(dependenciesResolver)
            .map { $0.flatMapCompletable { Command.play(data: $0, from: sequence) } }
    }
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
