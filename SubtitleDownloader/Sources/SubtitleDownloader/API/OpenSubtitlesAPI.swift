import Combine
import Foundation
import FoundationExtensions

public final class OpenSubtitlesAPI {
    public static func request(endpoint: OpenSubtitleEndpoint) -> Reader<Networking, Promise<(data: Data, response: URLResponse), URLError>> {
        Reader { dependencies in
            dependencies
                .http(endpoint.request.with {
                    $0.setValue(dependencies.userAgent().rawValue, forHTTPHeaderField: "User-Agent")
                    $0.setValue("application/json", forHTTPHeaderField: "Content-Type")
                })
        }
    }

    public static func search(_ params: SearchParameters) -> Reader<Networking, Promise<[SearchResponse], NetworkError>> {
        request(endpoint: .search(params))
            .flatMap { response in
                response
                    .validateStatusCode()
                    .decode([SearchResponse].self)
                    .mapValue { $0.promise }
                    .contramapEnvironment(\.decoder)
            }
    }

    public static func download(_ url: URL) -> Reader<Networking, Promise<Data, NetworkError>> {
        request(endpoint: .download(url))
            .mapValue { response in
                response
                    .map { $0.0 }
                    .mapError(NetworkError.urlError)
                    .promise
            }
    }

    public static func download(subtitle: SearchResponse) -> Reader<Networking, Promise<Data, NetworkError>> {
        download(subtitle.subDownloadLink)
    }
}
