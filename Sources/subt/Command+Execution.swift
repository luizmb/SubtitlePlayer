import Common
import Foundation
import RxSwift
import SubtitlePlayer

extension Command {
    func execute() -> Reader<Environment, Completable> {
        switch self {
        case let .play(arguments):
            return Command.play(with: arguments)
        case let .search(arguments):
            return Command.search(with: arguments)
        }
    }
}
