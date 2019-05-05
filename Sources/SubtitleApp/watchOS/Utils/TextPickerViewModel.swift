import Foundation

public typealias TextPickerViewModelOutput = (
    suggestions: ([String]) -> Void,
    selectItem: (Int) -> Void
)

public typealias TextPickerViewModelInput = (
    awakeWithContext: (Any?) -> Void,
    didAppear: () -> Void,
    willDisappear: () -> Void,
    indexSelected: (Int) -> Void
)

public func textPickerViewModel(items: [String], selectedIndex: Int?, completion: @escaping (String?) -> Void) -> (TextPickerViewModelOutput) -> TextPickerViewModelInput {
    return { output in

        var selectedIndex = selectedIndex ?? 0

        return (
            awakeWithContext: { _ in },
            didAppear: {
                output.suggestions(items)
                output.selectItem(selectedIndex)
            },
            willDisappear: { completion(items[selectedIndex]) },
            indexSelected: { selectedIndex = $0 }
        )
    }
}
