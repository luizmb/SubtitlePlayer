import Common
import Foundation
import OpenSubtitlesDownloader
import RxSwift
import SubtitlePlayer

public typealias LocalStorageItemViewModelInput = (
    itemSelected: (NSObject, Int) -> Void,
    itemDeleted: (NSObject, Int) -> Void
)

public typealias LocalStorageItemViewModelOutput = (
    title: (String) -> Void,
    season: (String) -> Void,
    language: (String) -> Void,
    file: (String) -> Void
)

public func localStorageItemViewModel(item: SubtitleFile, play: @escaping (SubtitleFile) -> Void, delete: @escaping (SubtitleFile) -> Void) -> (LocalStorageItemViewModelOutput) -> LocalStorageItemViewModelInput {
    return { output in
        output.title(item.title)
        output.season(item.formattedSeriesString ?? "")
        output.language(LanguageId(rawValue: item.language)?.description ?? item.language)
        output.file(item.filename)

        return (
            itemSelected: { _, _ in
                play(item)
            },
            itemDeleted: { _, _ in
                delete(item)
            }
        )
    }
}
