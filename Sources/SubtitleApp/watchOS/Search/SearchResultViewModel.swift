import Common
import Foundation
import OpenSubtitlesDownloader
import RxSwift

public typealias SearchResultViewModelOutput = (
    DisposeBag
)

public typealias SearchResultViewModelInput = (
    awakeWithContext: (Any?) -> Void,
    didAppear: () -> Void,
    willDisappear: () -> Void
)

public func searchResultViewModel(router: Router, searchParameters: SearchParameters) -> Reader<(URLSessionProtocol, UserAgent), (SearchResultViewModelOutput) -> SearchResultViewModelInput> {
    return OpenSubtitlesManager
        .search(searchParameters)
        .map { promiseResponse in
            { output in
                return (
                    awakeWithContext: { _ in
                        promiseResponse.subscribe(
                            onSuccess: { response in
                                print("Successful search")
                                print(response)
                            },
                            onError: { error in
                                print("Search error")
                                print(error)
                            }
                        ).disposed(by: output)
                    },
                    didAppear: { },
                    willDisappear: { }
                )
            }
        }
}

