import Common
import Foundation
import OpenSubtitlesDownloader
import RxSwift

public typealias SearchResultItemViewModelInput = (
    (NSObject, Int) -> Void
)

public typealias SearchResultItemViewModelOutput = (
    title: (String) -> Void,
    year: (String) -> Void,
    language: (String) -> Void,
    file: (String) -> Void,
    isDownloaded: (Bool) -> Void,
    isDownloading: (Bool) -> Void
)

public func searchResultItemViewModel(item: SearchResponse, disposeBag: DisposeBag) -> Reader<(URLSessionProtocol, UserAgent, FileManagerProtocol, GzipProtocol.Type, Persistence), (SearchResultItemViewModelOutput) -> SearchResultItemViewModelInput> {
    return Reader { urlSession, userAgent, fileManager, gzip, persistence in
        { output in
            output.title(item.movieName)
            output.year(item.formattedSeriesString ?? String(item.movieYear))
            output.language(item.languageName)
            output.file(item.subFileName)
            output.isDownloaded(
                persistence
                    .readDownloadedSubtitles()
                    .contains(where: { id, _, _ in id == item.idSubtitleFile })
            )
            output.isDownloading(false)

            let path = fileManager
                .specialFolder(FileManager.SearchPathDirectory.documentDirectory)
                .value!
                .appendingPathComponent("Subtitles", isDirectory: true)
                .appendingPathComponent(item.idSubtitleFile, isDirectory: true)
                .appendingPathComponent(item.subFileName, isDirectory: false)

            return ({ cell, index in
                output.isDownloading(true)
                fileManager
                    .ensureFolderExists(path.deletingLastPathComponent())
                    .analysis(
                        ifSuccess: { _ in
                            print("Folder exists: \(path.path)")
                    },
                        ifFailure: {
                            print("**** Error creating folder: \(path.path). Error: \($0)")
                    })

                OpenSubtitlesManager
                    .download(from: item.subDownloadLink, unzipInto: path.path)
                    .inject((urlSession, userAgent, fileManager, gzip))
                    .asCompletable()
                    .subscribe(
                        onCompleted: {
                            output.isDownloading(false)
                            output.isDownloaded(true)
                            persistence.insertDownloadedSubtitle(id: item.idSubtitleFile,
                                                                 url: item.subDownloadLink.absoluteString,
                                                                 file: path.path)
                    },
                        onError: { error in
                            output.isDownloading(false)
                            print("Error downloading file: \(error)")
                    })
                    .disposed(by: disposeBag)
            })
        }
    }
}
