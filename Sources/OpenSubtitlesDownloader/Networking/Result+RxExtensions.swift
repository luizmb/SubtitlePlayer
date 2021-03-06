import Foundation
import RxSwift

extension Result {
    public var asSingle: Single<Success> {
        return fold(ifSuccess: Single<Success>.just, ifFailure: { .error($0) })
    }
}
