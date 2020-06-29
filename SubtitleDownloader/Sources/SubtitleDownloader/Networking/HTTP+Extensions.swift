import Combine
import Foundation
import FoundationExtensions

extension Publisher where Output == (data: Data, response: URLResponse), Failure == URLError {
    public func validateStatusCode(_ customValidation: @escaping (HTTPURLResponse) -> Bool = { 200 ..< 300 ~= $0.statusCode }) -> AnyPublisher<Data, NetworkError> {
        mapError(NetworkError.urlError)
        .flatMapResult { (data, urlResponse) -> Result<Data, NetworkError> in
            (urlResponse as? HTTPURLResponse).map { httpResponse in
                customValidation(httpResponse)
                    ? .success(data)
                    : .failure(.invalidStatusCode(httpResponse.statusCode))
            } ?? Result.failure(NetworkError.unexpectedURLResponseType(urlResponse))
        }.eraseToAnyPublisher()
    }
}

extension Publisher where Output == Data {
    public func decode<T: Decodable>(_ type: T.Type) -> Reader<() -> JSONDecoder, AnyPublisher<T, NetworkError>> {
        Reader { decoder in
            self.decode(type: type, decoder: decoder())
                .mapError {
                    $0 as? DecodingError ?? DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: ""))
                }
                .mapError(NetworkError.decodingError)
                .eraseToAnyPublisher()
        }
    }
}

public enum NetworkError: Equatable, Error {
    case unknown
    case urlError(URLError)
    case unexpectedURLResponseType(URLResponse)
    case invalidStatusCode(Int)
    case decodingError(DecodingError)
}

extension DecodingError: Equatable {
    public static func ==(lhs: DecodingError, rhs: DecodingError) -> Bool {
        lhs.localizedDescription == rhs.localizedDescription
    }
}
