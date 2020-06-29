import ArgumentParser
import Foundation
import SubtitleDownloader

extension ImdbId: ExpressibleByArgument {
    public init?(argument: String) {
        guard let imdb = ImdbId(rawValue: argument) else { return nil }
        self = imdb
    }
}
