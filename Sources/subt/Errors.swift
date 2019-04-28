import Foundation

public struct UnknownCommand: Error {
}

public struct MissingArgument: Error {
    let argument: String
}
