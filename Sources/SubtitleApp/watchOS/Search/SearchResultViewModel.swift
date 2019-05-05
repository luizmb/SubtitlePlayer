import Common
import Foundation
import OpenSubtitlesDownloader
import RxSwift

public typealias SearchResultViewModelOutput = (
    disposeBag: DisposeBag,
    items: ([(title: String, year: String, language: String, file: String)]) -> Void
)

public typealias SearchResultViewModelInput = (
    awakeWithContext: (Any?) -> Void,
    didAppear: () -> Void,
    willDisappear: () -> Void,
    itemSelected: (InterfaceControllerProtocol, Int) -> Void
)

public func searchResultViewModel(router: Router, searchParameters: SearchParameters, completion: @escaping (SearchResponse?) -> Void) -> Reader<(URLSessionProtocol, UserAgent), (SearchResultViewModelOutput) -> SearchResultViewModelInput> {
    return OpenSubtitlesManager
        .search(searchParameters)
        .map { promiseResponse in
            var items: [SearchResponse] = []
            return { output in
                (
                    awakeWithContext: { _ in
                        promiseResponse.observeOn(MainScheduler.instance).subscribe(
                            onSuccess: { response in
                                items = response
                                return output.items(response.map {
                                    (
                                        title: $0.movieName,
                                        year: $0.formattedSeriesString ?? String($0.movieYear),
                                        language: $0.languageName,
                                        file: $0.subFileName
                                    )
                                })
                            },
                            onError: { error in
                                print("Search error")
                                print(error)
                            }
                        ).disposed(by: output.disposeBag)
                    },
                    didAppear: { },
                    willDisappear: { },
                    itemSelected: { view, index in
                        completion(items[safe: index])
                        view.dismiss()
                    }
                )
            }
        }
}

