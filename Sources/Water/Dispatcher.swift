//
//  Scheduler.swift
//  Water
//

import Combine
import SwiftUI

protocol Hookable {
    func hook(by dispatcher: Dispatcher)
    func prepare(by dispatcher: Dispatcher)
    func resolve(by dispatcher: Dispatcher)
}

extension Hookable {
    func hook(by dispatcher: Dispatcher) {}
    func prepare(by dispatcher: Dispatcher) {}
    func resolve(by dispatcher: Dispatcher) {}
}

protocol Storable {}

// FIXME: - Store State as LinkList
// FIXME: - cleanup dispatcher
class Dispatcher: ObservableObject {
    public let objectWillChange = PassthroughSubject<Void, Never>()

    var currentStateCursor = 0
//    var stateStore: [Int: StateStorage] = [:]

//    var pendingEffects: [HookEffect] = [] // FIXME: - clear the effects
    var currentEffectCursor = 0
//    var effectStore: [Int: EffectStorage] = [:]

    var hooks: [Any] = []
    
    var keyPathEnvironments: [AnyKeyPath: Any] = [:]

    var isScheduling = false

    init() {
//        print("hook state object init")
    }

    deinit {
        print("dispatcher deinit")
        // FIXME: - clear all resources
    }

    // define effect without run effect fn
    // FIXME: return ReactiveEffect<()>
    func setupRenderEffect() -> any Effectable {
        return ReactiveEffect {
            self.updateView()
        }
    }

    func tryCleanupRenderEffect() {
        if canTrack {
            shouldTrack = false
            activeEffect = nil
        }
    }

    func clear() {
        currentStateCursor = 0
//        stateStore.removeAll()

//        pendingEffects.removeAll()
        currentEffectCursor = 0
//        effectStore.removeAll()
    }

    func updateView() {
        if isScheduling {
            return
        }
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
}

private var dispatcherStore: [String: Dispatcher] = [:]

func useDispatcher(with identifier: String) -> Dispatcher {
    guard let dispatcher = dispatcherStore[identifier] else {
        let newDispatcher = Dispatcher()
        dispatcherStore[identifier] = newDispatcher
        return newDispatcher
    }
    return dispatcher
}
