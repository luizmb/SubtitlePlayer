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

        return OpenSubtitleAPI.search(searchParameters).map { searchPromise in
            searchPromise
                .do(onSuccess: printSearchResult)
                .asCompletable()
        }.contramap { ($0.urlSession(), $0.openSubtitlesUserAgent()) }
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
