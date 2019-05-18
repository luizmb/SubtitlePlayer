import Common
import Foundation
import OpenSubtitlesDownloader
import RxSwift
import SubtitlePlayer

public typealias LocalStorageViewModelOutput = (
    tableItems: ([(LocalStorageItemViewModelOutput) -> LocalStorageItemViewModelInput]) -> Void,
    scrollToRow: (Int) -> Void,
    controller: Controller
)

public typealias LocalStorageViewModelInput = (
    awakeWithContext: (Any?) -> Void,
    didAppear: () -> Void,
    willDisappear: () -> Void,
    plusTap: () -> Void,
    editTap: () -> Void
)

public func localStorageViewModel(router: Router)
    -> Reader<(FileManagerProtocol, Persistence), (LocalStorageViewModelOutput) -> LocalStorageViewModelInput> {
    var downloadedSubtitles: [SubtitleFile] = []

    return Reader { fileManager, persistence in
        let updateSubtitles: (
            ([(LocalStorageItemViewModelOutput) -> LocalStorageItemViewModelInput]) -> Void,
            Controller
        ) -> Void = { updateUI, controller in
            let old = downloadedSubtitles
            downloadedSubtitles = persistence.readDownloadedSubtitles()
            if old != downloadedSubtitles {
                updateUI(downloadedSubtitles.map {
                    localStorageItemViewModel(item: $0, play: { subtitle in
                        let filePath = SubtitleStorage.filePath(for: subtitle).inject(fileManager)
                        Subtitle
                            .from(filePath: filePath,
                                  encoding: persistence.readEncoding() ?? .utf8)
                            .inject(fileManager)
                            .analysis(
                                ifSuccess: { router.handle(.play(parent: controller, subtitle: $0)) },
                                ifFailure: { print("Error \($0)") })
                    })
                })
            }
        }

        return { output in (
            awakeWithContext: { _ in },
            didAppear: {
                updateSubtitles(output.tableItems, output.controller)
            },
            willDisappear: { },
            plusTap: { router.handle(.searchForm) },
            editTap: { print("edit") }
        )}
    }
}
