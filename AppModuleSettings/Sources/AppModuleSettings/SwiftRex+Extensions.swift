import Combine
import CombineRex
import Foundation
import SwiftRex
import SwiftUI

extension ObservableViewModel {
    func bind<V>(_ keyPath: KeyPath<StateType, V>, set action: @autoclosure @escaping () -> ActionType) -> Binding<V> {
        var temp: V?
        return .init(
            get: { temp ?? self.state[keyPath: keyPath] },
            set: { newValue in temp = newValue; self.dispatch(action()) }
        )
    }
    func bind<V>(_ keyPath: KeyPath<StateType, V>, set action: @escaping (V) -> ActionType) -> Binding<V> {
        var temp: V?
        return .init(
            get: { temp ?? self.state[keyPath: keyPath] },
            set: { newValue in temp = newValue; self.dispatch(action(newValue)) }
        )
    }
    func bind<V>(_ keyPath: KeyPath<StateType, V?>, fallback: V, set action: @escaping (V) -> ActionType) -> Binding<V> {
        var temp: V?
        return .init(
            get: { temp ?? self.state[keyPath: keyPath] ?? fallback },
            set: { newValue in temp = newValue; self.dispatch(action(newValue)) }
        )
    }
    func bind<V>(get: @escaping(StateType) -> V,
                 set action: @escaping (V) -> ActionType) -> Binding<V> {
        var temp: V?
        return .init(
            get: { temp ?? get(self.state) },
            set: { newValue in temp = newValue; self.dispatch(action(newValue)) }
        )
    }
}

extension Effect {
    static func fireAndForget(_ effect: @escaping () -> Void) -> Effect {
        Empty()
            .handleEvents(receiveSubscription: { _ in
                effect()
            })
            .asEffect
    }
}
