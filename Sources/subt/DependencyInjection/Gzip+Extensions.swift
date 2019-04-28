import Foundation
import Gzip
import OpenSubtitlesDownloader

public struct Gzip: GzipProtocol {
    public static func compress(_ data: Data) -> Result<Data, Error> {
        return data.isGzipped ? .success(data) : Result(catching: { try data.gzipped(level: .bestCompression) })
    }

    public static func decompress(_ data: Data) -> Result<Data, Error> {
        return data.isGzipped ? Result(catching: { try data.gunzipped() }) : .success(data)
    }
}
