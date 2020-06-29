import Combine
import Foundation
import FoundationExtensions

extension URLRequest {
    public func with(_ mutation: (inout URLRequest) -> Void) -> URLRequest {
        var request = self
        mutation(&request)
        return request
    }

    public func with<T>(_ keyPath: WritableKeyPath<URLRequest, T>, value: T) -> URLRequest {
        return with {
            $0[keyPath: keyPath] = value
        }
    }
}

extension Result where Success == URLRequest, Failure == Error {
    public func with(_ mutation: (inout URLRequest) -> Void) -> Result<Success, Error> {
        switch self {
        case .success(var request):
            mutation(&request)
            return .success(request)
        default: return self.map(identity).mapError(identity)
        }
    }

    public func with<T>(_ keyPath: WritableKeyPath<URLRequest, T>, value: T) -> Result<Success, Error> {
        return with {
            $0[keyPath: keyPath] = value
        }
    }
}
