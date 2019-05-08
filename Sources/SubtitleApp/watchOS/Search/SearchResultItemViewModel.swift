import Common
import Foundation
import OpenSubtitlesDownloader
import RxSwift
import SubtitlePlayer

public typealias SearchResultItemViewModelInput = (
    (NSObject, Int) -> Void
)

public enum BackgroundStatus {
    case remote
    case downloading
    case local
}

public typealias SearchResultItemViewModelOutput = (
    title: (String) -> Void,
    year: (String) -> Void,
    language: (String) -> Void,
    file: (String) -> Void,
    background: (BackgroundStatus) -> Void
)

public func searchResultItemViewModel(item: SearchResponse, disposeBag: DisposeBag) -> Reader<(URLSessionProtocol, UserAgent, FileManagerProtocol, GzipProtocol.Type, Persistence), (SearchResultItemViewModelOutput) -> SearchResultItemViewModelInput> {
    let file = subtitleFile(for: item)
    return Reader { urlSession, userAgent, fileManager, gzip, persistence in
        // TODO: Move to the table view model so reading won't happen every cell
        var downloadedSubtitlesList = persistence.readDownloadedSubtitles()
        let isDownloaded = { downloadedSubtitlesList.contains(where: { $0.id == file.id }) }

        return { output in
            output.title(item.movieName)
            output.year(item.formattedSeriesString ?? String(item.movieYear))
            output.language(item.languageName)
            output.file(item.subFileName)
            output.background(isDownloaded() ? .local : .remote)

            return ({ cell, index in
                // TODO: guard against isDownloading too
                guard !isDownloaded() else { return }
                output.background(.downloading)
                let folderPath = SubtitleStorage.folderPath(for: file).inject(fileManager)
                let filePath = SubtitleStorage.filePath(for: file).inject(fileManager)

                Single<String>.create(subscribe: { observer in
                    fileManager
                        .ensureFolderExists(folderPath, createIfNeeded: true)
                        .analysis(ifSuccess: { observer(.success($0)) },
                                  ifFailure: { observer(.error($0)) })
                    return Disposables.create()
                }).flatMapCompletable { _ in
                    OpenSubtitlesManager
                        .download(from: item.subDownloadLink, unzipInto: filePath)
                        .inject((urlSession, userAgent, fileManager, gzip))
                        .asCompletable()
                }.subscribe(
                    onCompleted: {
                        downloadedSubtitlesList = persistence.insertDownloadedSubtitle(file)
                        output.background(isDownloaded() ? .local : .remote)
                    },
                    onError: { error in
                        output.background(.remote)
                        print("Error downloading file: \(error)")
                    }
                ).disposed(by: disposeBag)
            })
        }
    }
}

private func subtitleFile(for searchResponse: SearchResponse) -> SubtitleFile {
    return .init(id: searchResponse.idSubtitleFile,
                 filename: searchResponse.subFileName,
                 title: searchResponse.movieName,
                 language: searchResponse.subLanguageID.rawValue,
                 season: searchResponse.seriesSeason,
                 episode: searchResponse.seriesEpisode)
}
