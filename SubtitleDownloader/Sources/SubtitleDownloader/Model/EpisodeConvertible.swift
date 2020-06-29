import Foundation
import FoundationExtensions

public protocol EpisodeConvertible {
    var season: String? { get }
    var episode: String? { get }
}

extension EpisodeConvertible {
    public var formattedSeriesString: String? {
        guard let episode = episode, let season = season else { return nil }
        guard !["", "0"].contains(episode) && !["", "0"].contains(season) else { return nil }
        return "S\(season.leftPadding(toLength: 2, withPad: "0"))E\(episode.leftPadding(toLength: 2, withPad: "0"))"
    }
}

