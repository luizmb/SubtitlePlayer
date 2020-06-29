import Combine
import Foundation
import FoundationExtensions

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
        [
            episode
                .map(String.init)
                .map { $0.prefixDashed("episode") },
            imdb
                .map(\.rawValue)
                .map { $0.prefixDashed("imdbid") },
            movieInfo
                .map(\.byteSize)
                .map(String.init)
                .map { $0.prefixDashed("moviebytesize") },
            movieInfo
                .map(\.hash)
                .map { $0.prefixDashed("moviehash") },
            query
                .flatMap(\.urlEncoded)
                .map { $0.prefixDashed("query") },
            season
                .map(String.init)
                .map { $0.prefixDashed("season") },
            language
                .rawValue
                .prefixDashed("sublanguageid"),
            tag
                .flatMap(\.urlEncoded)
                .map { $0.prefixDashed("tag") }
        ]
        .compactMap(identity)
    }
}

extension String {
    fileprivate var urlEncoded: String? {
        addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    }

    fileprivate var prefixDashed: (String) -> String {
        { prefix in
            "\(prefix)-\(self)"
        }
    }
}
