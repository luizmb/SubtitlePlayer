import Foundation

enum Command {
    case download([DownloadArgument])
    case play([PlayArgument])
    case search([SearchArgument])
}

extension Command {
    static func parse(_ arguments: [String]) -> Result<Command, Error> {
        switch arguments.first {
        case "play": return .success(.play(.parse(Array(arguments.dropFirst()))))
        case "search": return .success(.search(.parse(Array(arguments.dropFirst()))))
        case "download": return .success(.download(.parse(Array(arguments.dropFirst()))))
        default: return .failure(UnknownCommandError())
        }
    }
}
