import Common
import Foundation
import OpenSubtitlesDownloader

public struct Environment {
    public let now: () -> Date
    public let urlSession: () -> URLSessionProtocol
    public let openSubtitlesUserAgent: () -> UserAgent
    public let fileManager: () -> FileManagerProtocol
    public let gzip: () -> GzipProtocol.Type
}
