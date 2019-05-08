import Common
import Foundation

public struct SubtitleFile: Codable {
    public let id: String
    public let filename: String
    public let title: String
    public let season: String?
    public let episode: String?

    public init(id: String, filename: String, title: String, season: String?, episode: String?) {
        self.id = id
        self.filename = filename
        self.title = title
        self.season = season
        self.episode = episode
    }
}

public struct SubtitleStorage {
    public static func folderURL(for file: SubtitleFile) -> Reader<FileManagerProtocol, URL> {
        return Reader { fileManager in
            fileManager
                .specialFolder(.documentDirectory)
                .value!
                .appendingPathComponent("Subtitles", isDirectory: true)
                .appendingPathComponent(file.id, isDirectory: true)
        }
    }

    public static func fileURL(for file: SubtitleFile) -> Reader<FileManagerProtocol, URL> {
        return folderURL(for: file).map { $0.appendingPathComponent(file.filename, isDirectory: false) }
    }

    public static func folderPath(for file: SubtitleFile) -> Reader<FileManagerProtocol, String> {
        return folderURL(for: file).map(^\.path)
    }

    public static func filePath(for file: SubtitleFile) -> Reader<FileManagerProtocol, String> {
        return fileURL(for: file).map(^\.path)
    }
}
