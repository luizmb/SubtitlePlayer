import Common
import Foundation
import OpenSubtitlesDownloader
import RxSwift

public typealias SearchResultViewModelOutput = (
    tableItems: ([(SearchResultItemViewModelOutput) -> SearchResultItemViewModelInput]) -> Void,
    scrollToRow: (Int) -> Void
)

public typealias SearchResultViewModelInput = (
    awakeWithContext: (Any?) -> Void,
    didAppear: () -> Void,
    willDisappear: () -> Void
)

public func searchResultViewModel(router: Router, searchParameters: SearchParameters)
    -> Reader<(URLSessionProtocol, UserAgent, FileManagerProtocol, GzipProtocol.Type, Persistence), (SearchResultViewModelOutput)
    -> SearchResultViewModelInput> {
    let disposeBag = DisposeBag()
    return Reader { deps in
        let (urlSession, userAgent, _, _, _) = deps
        return OpenSubtitlesManager
            .search(searchParameters)
            .map { request in
                { output in (
                    awakeWithContext: awakeWithContext(request: request,
                                                       handleSuccess: handleResponse(itemsUpdated: output.tableItems,
                                                                                     disposeBag: disposeBag).inject(deps),
                                                       handleError: handleError,
                                                       disposeBag: disposeBag),
                    didAppear: { },
                    willDisappear: { }
                )}
            }.inject((urlSession, userAgent))
    }
}

private func awakeWithContext(request: Single<[SearchResponse]>,
                      handleSuccess: @escaping ([SearchResponse]) -> Void,
                      handleError: @escaping (Error) -> Void,
                      disposeBag: DisposeBag) -> (Any?) -> Void {
    return { _ in
        request.observeOn(MainScheduler.instance).subscribe(
            onSuccess: handleSuccess,
            onError: handleError
        ).disposed(by: disposeBag)
    }
}

private func handleResponse(itemsUpdated: @escaping ([(SearchResultItemViewModelOutput) -> SearchResultItemViewModelInput]) -> Void,
                            disposeBag: DisposeBag)
    -> Reader<(URLSessionProtocol, UserAgent, FileManagerProtocol, GzipProtocol.Type, Persistence), ([SearchResponse]) -> Void> {
    return Reader { deps in
        { response in
            itemsUpdated(response.map { searchResultItemViewModel(item: $0, disposeBag: disposeBag).inject(deps) })
        }
    }
}

private func handleError(_ error: Error) {
    print("Search error")
    print(error)
}
