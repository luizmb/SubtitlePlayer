import Foundation
import RxSwift

extension URLSessionProtocol {
    public func data(with request: URLRequest) -> Observable<(HTTPURLResponse, Data)> {
        return Observable.create { observer in
            let task = self.dataTask(with: request) { data, response, error in
                guard let response = response, let data = data else {
                    observer.on(.error(error ?? NetworkError.unknown))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    observer.on(.error(NetworkError.unexpectedURLResponseType(response: response)))
                    return
                }

                observer.on(.next((httpResponse, data)))
                observer.on(.completed)
            }

            task.resume()

            return Disposables.create(with: task.cancel)
        }
    }
}

extension Observable where Element == (HTTPURLResponse, Data) {
    public func validateStatusCode(_ customValidation: @escaping (HTTPURLResponse) -> Bool = { 200 ..< 300 ~= $0.statusCode }) -> Observable<(HTTPURLResponse, Data)> {
        return flatMap { (urlResponse, data) -> Observable<(HTTPURLResponse, Data)> in
            if customValidation(urlResponse) {
                return Observable<(HTTPURLResponse, Data)>.just((urlResponse, data))
            } else {
                return Observable<(HTTPURLResponse, Data)>.error(NetworkError.invalidStatusCode(urlResponse.statusCode))
            }
        }
    }

    public func json<Model: Decodable>(_ type: Model.Type, jsonDecoder: JSONDecoder = .init()) -> Observable<Model> {
        return flatMap { _, data in
            Result(catching: { try jsonDecoder.decode(type, from: data) })
                .fold(
                    ifSuccess: Observable<Model>.just,
                    ifFailure: Observable<Model>.error
                )
        }
    }
}

enum NetworkError: Error {
    case unknown
    case unexpectedURLResponseType(response: URLResponse)
    case invalidStatusCode(Int)
}
