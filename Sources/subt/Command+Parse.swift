import Foundation
import RxSwift

extension Command {
    static func parse(_ arguments: [String]) -> Observable<Command> {
        switch arguments.first {
        case "play": return .just(.play(.parse(Array(arguments.dropFirst()))))
        case "search": return .just(.search(.parse(Array(arguments.dropFirst()))))
        default: return .error(UnknownCommand())
        }
    }
}
