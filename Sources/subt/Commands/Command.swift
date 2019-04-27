import Common
import Foundation
import RxSwift
import SubtitlePlayer

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
        default: return .failure(UnknownCommand())
        }
    }
}

extension Command {
    func execute() -> Reader<Environment, Completable> {
        switch self {
        case let .download(arguments):
            return Command.download(with: arguments)
        case let .play(arguments):
            return Command.play(with: arguments)
        case let .search(arguments):
            return Command.search(with: arguments)
        }
    }
}
