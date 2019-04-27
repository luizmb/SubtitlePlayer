import Common
import Foundation
import OpenSubtitlesDownloader
import RxSwift
import SubtitlePlayer

extension Command {
    static func search(with arguments: [SearchArgument]) -> Reader<Environment, Completable> {
        let searchParameters = SearchParameters(
            imdb: arguments.first(where: { $0.imdb != nil }).flatMap(^\.imdb),
            movieInfo: zip(
                arguments.first(where: { $0.byteSize != nil }).flatMap(^\.byteSize),
                arguments.first(where: { $0.hash != nil }).flatMap(^\.hash)
            ).flatMap(MovieInfo.init),
            query: arguments.first(where: { $0.query != nil }).flatMap(^\.query),
            episode: arguments.first(where: { $0.episode != nil }).flatMap(^\.episode),
            season: arguments.first(where: { $0.season != nil }).flatMap(^\.season),
            language: arguments.first(where: { $0.language != nil }).flatMap(^\.language) ?? .all,
            tag: arguments.first(where: { $0.tag != nil }).flatMap(^\.tag)
        )

        return OpenSubtitleAPI
            .search(searchParameters)
            .map { $0.do(onSuccess: printSearchResult) }
            .map { $0.asCompletable() }
            .contramap { ($0.urlSession(), $0.openSubtitlesUserAgent()) }
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
                ID:      \t\($0.idSubtitle)
                Link:    \t\($0.zipDownloadLink)

                """
            }.joined(separator: "\n")
    )
}
