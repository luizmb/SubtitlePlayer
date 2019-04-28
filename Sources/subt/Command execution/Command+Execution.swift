import Common
import Foundation
import RxSwift

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
