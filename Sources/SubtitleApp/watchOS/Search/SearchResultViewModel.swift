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
    willDisappear: () -> Void
)

public func searchResultViewModel(router: Router, searchParameters: SearchParameters) -> Reader<(URLSessionProtocol, UserAgent), (SearchResultViewModelOutput) -> SearchResultViewModelInput> {
    return OpenSubtitlesManager
        .search(searchParameters)
        .map { promiseResponse in
            { output in
                return (
                    awakeWithContext: { _ in
                        promiseResponse.observeOn(MainScheduler.instance).subscribe(
                            onSuccess: { response in
                                let formatter = NumberFormatter()
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
                    willDisappear: { }
                )
            }
        }
}

