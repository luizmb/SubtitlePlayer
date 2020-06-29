import Combine
import Foundation

public typealias Promise = Publishers.Promise
public typealias HTTP = (URLRequest) -> Promise<(data: Data, response: URLResponse), URLError>
public typealias Gzip = (compress: (Data) -> Result<Data, Error>, decompress: (Data) -> Result<Data, Error>)
public typealias FileSave = (Data, String) -> Result<String, Error>

public typealias Dependencies = (
    networking: Networking,
    fileSave: FileSave,
    gzip: Gzip,
    decoder: () -> JSONDecoder
)
public typealias Networking = (
    http: HTTP,
    userAgent: () -> UserAgent,
    decoder: () -> JSONDecoder
)
public typealias FileSystem = (
    fileSave: FileSave,
    gzip: Gzip
)
