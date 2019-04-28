import Common
import Foundation

public struct SearchParameters {
    public let imdb: ImdbId?
    public let movieInfo: MovieInfo?
    public let query: String?
    public let episode: Int?
    public let season: Int?
    public let language: LanguageId
    public let tag: String?

    public init(imdb: ImdbId? = nil,
                movieInfo: MovieInfo? = nil,
                query: String? = nil,
                episode: Int? = nil,
                season: Int? = nil,
                language: LanguageId = .all,
                tag: String? = nil) {
        self.imdb = imdb
        self.movieInfo = movieInfo
        self.query = query
        self.episode = episode
        self.season = season
        self.language = language
        self.tag = tag
    }
}

extension SearchParameters {
    public func toQueryParameters() -> [String] {
        return ([
            episode
                .map(String.init)
                .map(^\.prefixDashed)
                .apply("episode"),
            imdb
                .map(^\.rawValue.prefixDashed)
                .apply("imdbid"),
            movieInfo
                .map(^\.byteSize)
                .map(String.init)
                .map(^\.prefixDashed)
                .apply("moviebytesize"),
            movieInfo
                .map(^\.hash.prefixDashed)
                .apply("moviehash"),
            query
                .flatMap(^\.urlEncoded?.prefixDashed)
                .apply("query"),
            season
                .map(String.init)
                .map(^\.prefixDashed)
                .apply("season"),
            language
                .rawValue
                .prefixDashed("sublanguageid"),
            tag
                .flatMap(^\.urlEncoded?.prefixDashed)
                .apply("tag")
        ] as [String?]).compactMap(identity)
    }
}

extension String {
    fileprivate var urlEncoded: String? {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    }

    fileprivate var prefixDashed: (String) -> String {
        return { prefix in
            "\(prefix)-\(self)"
        }
    }
}
