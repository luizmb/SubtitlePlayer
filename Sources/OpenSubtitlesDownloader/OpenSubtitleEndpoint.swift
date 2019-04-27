import Foundation

public enum OpenSubtitleEndpoint {
    case search(SearchParameters)
    case download(URL)
}

extension OpenSubtitleEndpoint {
    public var request: URLRequest {
        switch self {
        case let .search(parameters):
            var url = baseUrl
            parameters.toQueryParameters().forEach {
                url = url.appendingPathComponent($0, isDirectory: true)
            }
            return URLRequest(url: url)
                .with(\URLRequest.httpMethod, value: httpMethod.description)
                .with { request in
                    headers.forEach { key, value in
                        request.setValue(value, forHTTPHeaderField: key)
                    }
                }
        case .download:
            return URLRequest(url: baseUrl)
                .with(\URLRequest.httpMethod, value: httpMethod.description)
                .with { request in
                    headers.forEach { key, value in
                        request.setValue(value, forHTTPHeaderField: key)
                    }
                }
        }
    }

    public var baseUrl: URL {
        switch self {
        case let .download(url): return url
        case .search: return URL(string: "https://rest.opensubtitles.org/search/")!
        }
    }

    public var httpMethod: HTTPMethod {
        return .get
    }

    public var headers: [(key: String, value: String)] {
        return []
    }
}
