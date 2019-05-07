import Common
import Foundation
import OpenSubtitlesDownloader
import RxSwift

public typealias SearchResultViewModelOutput = (
    disposeBag: DisposeBag,
    items: ([(SearchResultItemViewModelOutput) -> SearchResultItemViewModelInput]) -> Void
)

public typealias SearchResultViewModelInput = (
    awakeWithContext: (Any?) -> Void,
    didAppear: () -> Void,
    willDisappear: () -> Void
)

public func searchResultViewModel(router: Router, searchParameters: SearchParameters) -> Reader<(URLSessionProtocol, UserAgent, FileManagerProtocol, GzipProtocol.Type, Persistence), (SearchResultViewModelOutput) -> SearchResultViewModelInput> {
    return Reader { urlSession, userAgent, fileManager, gzip, persistence in
        OpenSubtitlesManager
            .search(searchParameters)
            .map { promiseResponse in
                { output in
                    (
                        awakeWithContext: { _ in
                            promiseResponse.observeOn(MainScheduler.instance).subscribe(
                                onSuccess: { response in
                                    output.items(
                                        response.map {
                                            searchResultItemViewModel(item: $0, disposeBag: output.disposeBag)
                                                .inject((urlSession, userAgent, fileManager, gzip, persistence))
                                        }
                                    )
                                },
                                onError: { error in
                                    print("Search error")
                                    print(error)
                                }
                            ).disposed(by: output.disposeBag)
                        },
                        didAppear: { },
                        willDisappear: { }
                    )
                }
            }
            .inject((urlSession, userAgent))
    }
}

