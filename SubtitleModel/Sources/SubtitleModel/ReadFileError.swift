import Foundation

public enum ReadFileError: Error {
    case cannotReadFile(path: String, error: Error)
}
