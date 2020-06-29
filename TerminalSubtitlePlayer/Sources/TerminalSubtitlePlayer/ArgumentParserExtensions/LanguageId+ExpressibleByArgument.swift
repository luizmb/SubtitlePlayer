import ArgumentParser
import Foundation
import SubtitleDownloader

extension LanguageId: ExpressibleByArgument {
    public init?(argument: String) {
        guard let imdb = LanguageId(rawValue: argument) else { return nil }
        self = imdb
    }
}
