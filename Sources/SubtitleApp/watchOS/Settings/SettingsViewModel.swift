import Common
import Foundation
import RxSwift
import SubtitlePlayer

public typealias SettingsViewModelInput = (
    awakeWithContext: (Any?) -> Void,
    didAppear: () -> Void,
    willDisappear: () -> Void,
    encodingButtonTap: (Controller) -> Void
)

public typealias SettingsViewModelOutput = (
    encodingLabelString: (String) -> Void,
    _: Void
)

private let encodingPickerSuggestions =  String.Encoding.allCases.compactMap(^\.shortName).sorted()

public func settingsViewModel(router: Router) -> Reader<Persistence, (SettingsViewModelOutput) -> SettingsViewModelInput> {
    return Reader { persistence in
        { output in
            var currentEncoding = persistence.readEncoding() ?? .utf8

            let updateView = {
                output.encodingLabelString(currentEncoding.shortName ?? "")
            }

            return (
                awakeWithContext: { _ in },
                didAppear: updateView,
                willDisappear: { },
                encodingButtonTap: encodingButtonTap(router: router,
                                                     persistence: persistence,
                                                     currentEncoding: { currentEncoding },
                                                     updateCurrentEncoding: { currentEncoding = $0 ?? currentEncoding },
                                                     updateView: updateView)
            )
        }
    }
}

private func encodingButtonTap(router: Router,
                               persistence: Persistence,
                               currentEncoding: @escaping () -> String.Encoding,
                               updateCurrentEncoding: @escaping (String.Encoding?) -> Void,
                               updateView: @escaping () -> Void) -> (Controller) -> Void {
    return { view in
        router.handle(
            .textPicker(
                parent: view,
                empty: nil,
                suggestions: encodingPickerSuggestions,
                selectedIndex: currentEncoding().shortName.flatMap(encodingPickerSuggestions.firstIndex(of:)),
                completion: { choice in
                    let chosenEncoding = choice?.some.flatMap(String.Encoding.init(string:))
                    chosenEncoding.map {
                        persistence.saveEncoding($0)
                    }
                    updateCurrentEncoding(chosenEncoding)
                    updateView()
                }
            )
        )
    }
}
