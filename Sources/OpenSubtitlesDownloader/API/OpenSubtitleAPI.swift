import Common
import Foundation
import RxSwift

public final class OpenSubtitleAPI {
    public static func request(endpoint: OpenSubtitleEndpoint) -> Reader<(URLSessionProtocol, UserAgent), Observable<(HTTPURLResponse, Data)>> {
        return Reader { (urlSession, userAgent) -> Observable<(HTTPURLResponse, Data)> in
            return urlSession
                .data(with: endpoint.request.with {
                    $0.setValue(userAgent.rawValue, forHTTPHeaderField: "User-Agent")
                    $0.setValue("application/json", forHTTPHeaderField: "Content-Type")
                })
        }
    }

    public static func search(_ params: SearchParameters) -> Reader<(URLSessionProtocol, UserAgent), Single<[SearchResponse]>> {
        return request(endpoint: .search(params))
            .map { $0.json([SearchResponse].self).asSingle() }
    }

    public static func download(_ url: URL) -> Reader<(URLSessionProtocol, UserAgent), Single<Data>> {
        return request(endpoint: .download(url))
            .map { $0.map { $0.1 }.asSingle() }
    }

    public static func download(subtitle: SearchResponse) -> Reader<(URLSessionProtocol, UserAgent), Single<Data>> {
        return request(endpoint: .download(subtitle.subDownloadLink))
            .map { $0.map { $0.1 }.asSingle() }
    }
}
