import Foundation
import FoundationExtensions

public struct SubtitleFile: EpisodeConvertible {
    public let id: String
    public let filename: String
    public let title: String
    public let language: String
    public let season: String?
    public let episode: String?

    public init(id: String, filename: String, title: String, language: String, season: String?, episode: String?) {
        self.id = id
        self.filename = filename
        self.title = title
        self.language = language
        self.season = season
        self.episode = episode
    }
}

extension SubtitleFile {
    public static func from(searchResponse: SearchResponse) -> SubtitleFile {
        SubtitleFile(
            id: searchResponse.idSubtitleFile,
            filename: searchResponse.subFileName,
            title: searchResponse.movieName,
            language: searchResponse.subLanguageID.rawValue,
            season: searchResponse.season,
            episode: searchResponse.episode
        )
    }
}
