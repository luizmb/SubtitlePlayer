import Foundation
import RxSwift

enum Command {
    case play([PlayArgument])
    case search([SearchArgument])
}
