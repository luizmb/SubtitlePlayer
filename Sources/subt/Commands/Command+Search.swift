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

        let initialLine = arguments.firstNonNil(^\.line)

        return arguments
            .firstNonNil(^\.play)
            .fold(
                ifSome: { searchAndPlay(parameters: searchParameters, resultIndex: $0, sequence: initialLine) },
                ifNone: { searchOnly(parameters: searchParameters) }
            )
    }

    static func searchOnly(parameters: SearchParameters) -> Reader<Environment, Completable> {
        return OpenSubtitleAPI.search(parameters).map { searchPromise in
            searchPromise.do(onSuccess: printSearchResult).asCompletable()
        }.contramap { ($0.urlSession(), $0.openSubtitlesUserAgent()) }
    }

    static func searchAndPlay(parameters: SearchParameters, resultIndex: Int, sequence: Int?) -> Reader<Environment, Completable> {
        return Reader { environment in
            return OpenSubtitleAPI
                .search(parameters)
                .inject((environment.urlSession(), environment.openSubtitlesUserAgent()))
                .flatMap { (results: [SearchResponse]) -> Single<SearchResponse> in
                    results[safe: resultIndex]
                        .toResult(orError: ResultIndexOutOfBoundsError(index: resultIndex))
                        .asSingle
                }
                .flatMap { response in
                    OpenSubtitleAPI
                        .download(subtitle: response)
                        .inject((environment.urlSession(), environment.openSubtitlesUserAgent()))
                }
                .flatMap {
                    environment
                        .gzip()
                        .decompress($0)
                        .asSingle
                }
                .flatMap {
                    Subtitle
                        .from(data: $0, encoding: .isoLatin1)
                        .toResult(orError: InvalidSubtitleError())
                        .asSingle

                }
                .flatMapCompletable { subtitle in
                    Command.play(subtitle: subtitle, from: sequence ?? 0)
                }
        }
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

private func downloadAndPlay(item: SearchResponse) -> Reader<Environment, Completable> {
    return Command.download(with: [
        .play(true),
        .subtitleURL(item.subDownloadLink),
        .destination("\(UUID().uuidString).tmp")
    ])
}
