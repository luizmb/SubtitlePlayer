import Common
import Foundation

public struct SubtitleFile: Codable, Equatable {
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
    public var formattedSeriesString: String? {
        guard let episode = episode, let season = season else { return nil }
        guard !["", "0"].contains(episode) && !["", "0"].contains(season) else { return nil }
        return "S\(season.leading(char: "0", toLength: 2))E\(episode.leading(char: "0", toLength: 2))"
    }
}

public struct SubtitleStorage {
    public static func folderURL(for file: SubtitleFile) -> Reader<FileManagerProtocol, URL> {
        return subtitlesFolder(id: file.id)
    }

    public static func fileURL(for file: SubtitleFile) -> Reader<FileManagerProtocol, URL> {
        return subtitlesFile(id: file.id, filename: file.filename)
    }

    public static func folderPath(for file: SubtitleFile) -> Reader<FileManagerProtocol, String> {
        return folderURL(for: file).map(^\.path)
    }

    public static func filePath(for file: SubtitleFile) -> Reader<FileManagerProtocol, String> {
        return fileURL(for: file).map(^\.path)
    }

    public static func delete(subtitle: SubtitleFile) -> Reader<FileManagerProtocol, Bool> {
        return Reader { fileManager in
            let file = subtitlesFile(id: subtitle.id, filename: subtitle.filename).inject(fileManager)
            return fileManager.delete(file: file).fold(ifSuccess: { _ in true }, ifFailure: { _ in false })
        }
    }

    private static func subtitlesParentFolder() -> Reader<FileManagerProtocol, URL> {
        return Reader { fileManager in
            fileManager
                .specialFolder(.documentDirectory)
                .value!
                .appendingPathComponent("Subtitles", isDirectory: true)
        }
    }

    private static func subtitlesFolder(id: String) -> Reader<FileManagerProtocol, URL> {
        return subtitlesParentFolder().map { $0.appendingPathComponent(id, isDirectory: true) }
    }

    private static func subtitlesFile(id: String, filename: String) -> Reader<FileManagerProtocol, URL> {
        return subtitlesFolder(id: id).map { $0.appendingPathComponent(filename, isDirectory: false) }
    }
}
