import Foundation

public enum SubtitleDecodingError: Error {
    case binaryDataCannotBeRepresentedAsString(encoding: String.Encoding)
    case stringCannotBeRepresentedAsSubtitle(String)
    case readFileError(ReadFileError)
}
