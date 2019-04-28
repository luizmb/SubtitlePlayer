import Foundation
import OpenSubtitlesDownloader

enum SearchArgument {
    case query(String)
    case season(Int)
    case episode(Int)
    case tag(String)
    case imdb(ImdbId)
    case language(LanguageId)
    case byteSize(Int)
    case hash(String)
    case play(index: Int)
    case initialLine(Int)
    case encoding(String.Encoding)

    static func parse(_ argument: String) -> SearchArgument? {
        let components = argument.components(separatedBy: "=")
        switch components.first {
        case "query":
            return components[safe: 1].map(SearchArgument.query)
        case "season":
            return components[safe: 1].flatMap(Int.init).map(SearchArgument.season)
        case "episode":
            return components[safe: 1].flatMap(Int.init).map(SearchArgument.episode)
        case "tag":
            return components[safe: 1].map(SearchArgument.tag)
        case "imdb":
            return components[safe: 1].flatMap(ImdbId.init).map(SearchArgument.imdb)
        case "language":
            return components[safe: 1].flatMap(LanguageId.init).map(SearchArgument.language)
        case "byte-size":
            return components[safe: 1].flatMap(Int.init).map(SearchArgument.byteSize)
        case "hash":
            return components[safe: 1].map(SearchArgument.hash)
        case "play":
            return components[safe: 1].flatMap(Int.init).map(SearchArgument.play)
        case "from-line":
            return components[safe: 1].flatMap(Int.init).map(SearchArgument.initialLine)
        case "encoding":
            return components[safe: 1].flatMap(String.Encoding.init(string:)).map(SearchArgument.encoding)
        default:
            return nil
        }
    }
}

extension SearchArgument {
    var query: String? {
        guard case let .query(query) = self else { return nil }
        return query
    }

    var season: Int? {
        guard case let .season(season) = self else { return nil }
        return season
    }

    var episode: Int? {
        guard case let .episode(episode) = self else { return nil }
        return episode
    }

    var tag: String? {
        guard case let .tag(tag) = self else { return nil }
        return tag
    }

    var imdb: ImdbId? {
        guard case let .imdb(imdb) = self else { return nil }
        return imdb
    }

    var language: LanguageId? {
        guard case let .language(language) = self else { return nil }
        return language
    }

    var byteSize: Int? {
        guard case let .byteSize(byteSize) = self else { return nil }
        return byteSize
    }

    var hash: String? {
        guard case let .hash(hash) = self else { return nil }
        return hash
    }

    var play: Int? {
        guard case let .play(play) = self else { return nil }
        return play
    }

    var line: Int? {
        guard case let .initialLine(line) = self else { return nil }
        return line
    }

    var encoding: String.Encoding? {
        guard case let .encoding(encoding) = self else { return nil }
        return encoding
    }
}

extension Array where Element == SearchArgument {
    static func parse(_ arguments: [String]) -> [SearchArgument] {
        return arguments.compactMap(SearchArgument.parse)
    }
}
