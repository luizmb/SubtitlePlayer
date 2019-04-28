import Foundation

public struct FileNotFoundError: Error {
    let path: String
}

public struct UnknownCommand: Error {
}

public struct MissingArgument: Error {
    let argument: String
}

public struct InvalidSubtitleError: Error {
}
