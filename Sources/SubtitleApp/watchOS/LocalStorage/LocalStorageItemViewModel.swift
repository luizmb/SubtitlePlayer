import Common
import Foundation
import OpenSubtitlesDownloader
import RxSwift
import SubtitlePlayer

public typealias LocalStorageItemViewModelInput = (
    (NSObject, Int) -> Void
)

public typealias LocalStorageItemViewModelOutput = (
    title: (String) -> Void,
    season: (String) -> Void,
    language: (String) -> Void,
    file: (String) -> Void
)

public func localStorageItemViewModel(item: SubtitleFile, play: @escaping (SubtitleFile) -> Void) -> (LocalStorageItemViewModelOutput) -> LocalStorageItemViewModelInput {
    return { output in
        output.title(item.title)
        output.season(item.formattedSeriesString ?? "")
        output.language(LanguageId(rawValue: item.language)?.description ?? item.language)
        output.file(item.filename)

        return ({ _, _ in
            play(item)
        })
    }
}
