import Common
import Foundation
import OpenSubtitlesDownloader
import RxSwift
import SubtitlePlayer

public typealias LocalStorageViewModelOutput = (
    tableItems: ([(LocalStorageItemViewModelOutput) -> LocalStorageItemViewModelInput]) -> Void,
    editMode: (Bool) -> Void,
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

    return Reader { fileManager, persistence in
        { output in
            var editMode = false
            var cacheIds: [String]?

            func setDownloadedSubtitles(_ newValue: [SubtitleFile]) -> Void {
                let newValueIds = newValue.map(^\.id)
                guard newValueIds != cacheIds else { return }
                cacheIds = newValueIds

                output.tableItems(
                    reloadTable(router: router,
                                fileManager: fileManager,
                                persistence: persistence,
                                controller: output.controller,
                                list: { newValue },
                                updateList: { setDownloadedSubtitles($0) })
                )
            }

            return (
                awakeWithContext: { _ in },
                didAppear: {
                    setDownloadedSubtitles(persistence.readDownloadedSubtitles())
                },
                willDisappear: { },
                plusTap: { router.handle(.searchForm) },
                editTap: {
                    editMode.toggle()
                    output.editMode(editMode)
                }
            )
        }
    }
}

private func reloadTable(router: Router,
                         fileManager: FileManagerProtocol,
                         persistence: Persistence,
                         controller: Controller,
                         list: () -> [SubtitleFile],
                         updateList: @escaping ([SubtitleFile]) -> Void) -> [(LocalStorageItemViewModelOutput) -> LocalStorageItemViewModelInput] {
    return list().map {
        localStorageItemViewModel(
            item: $0,
            play: playButtonTap(router: router,
                                fileManager: fileManager,
                                persistence: persistence,
                                view: controller),
            delete: deleteButtonTap(fileManager: fileManager,
                                    persistence: persistence,
                                    updateList: updateList)
        )
    }
}

private func playButtonTap(router: Router,
                           fileManager: FileManagerProtocol,
                           persistence: Persistence,
                           view: Controller) -> (SubtitleFile) -> Void {
    return { subtitle in
        let filePath = SubtitleStorage.filePath(for: subtitle).inject(fileManager)
        Subtitle
            .from(filePath: filePath,
                  encoding: persistence.readEncoding() ?? .utf8)
            .inject(fileManager)
            .analysis(
                ifSuccess: { router.handle(.play(parent: view, subtitle: $0)) },
                ifFailure: { print("Error \($0)") })
    }
}

private func deleteButtonTap(fileManager: FileManagerProtocol,
                             persistence: Persistence,
                             updateList: @escaping ([SubtitleFile]) -> Void) -> (SubtitleFile) -> Void {
    return { subtitle in
        guard SubtitleStorage.delete(subtitle: subtitle).inject(fileManager) else { return }
        updateList(
            persistence.deleteDownloadedSubtitle(subtitle)
        )
    }
}
