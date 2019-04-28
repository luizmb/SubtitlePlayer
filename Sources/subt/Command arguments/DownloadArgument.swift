import Foundation

enum DownloadArgument {
    case subtitleURL(URL)
    case destination(String)
    case play(Bool)
    case encoding(String.Encoding)

    static func parse(_ argument: String) -> DownloadArgument? {
        let components = argument.components(separatedBy: "=")
        switch components.first {
        case "url":
            return components[safe: 1].flatMap(URL.init(string:)).map(DownloadArgument.subtitleURL)
        case "into":
            return components[safe: 1].map(DownloadArgument.destination)
        case "play":
            return components[safe: 1].flatMap(Bool.init).map(DownloadArgument.play)
        case "encoding":
            return components[safe: 1].flatMap(String.Encoding.init(string:)).map(DownloadArgument.encoding)
        default:
            return nil
        }
    }
}

extension DownloadArgument {
    var subtitleURL: URL? {
        guard case let .subtitleURL(subtitleURL) = self else { return nil }
        return subtitleURL
    }

    var destination: String? {
        guard case let .destination(destination) = self else { return nil }
        return destination
    }

    var play: Bool? {
        guard case let .play(play) = self else { return nil }
        return play
    }

    var encoding: String.Encoding? {
        guard case let .encoding(encoding) = self else { return nil }
        return encoding
    }
}

extension Array where Element == DownloadArgument {
    static func parse(_ arguments: [String]) -> [DownloadArgument] {
        return arguments.compactMap(DownloadArgument.parse)
    }
}
