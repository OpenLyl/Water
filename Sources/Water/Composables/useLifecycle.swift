//
//  useLifeCycle.swift
//  Water
//

import Foundation

// TODO: - high abstract the func with createHook

public func onMounted(hookFn: @escaping () -> Void, identifier: String = #function) {
    let viewIdentifier = useViewIdentifier(identifier: identifier, callStackSymbols: Thread.callStackSymbols)
    let dispatcher = useDispatcher(with: viewIdentifier)
    dispatcher.mountHook = hookFn
}

public func onUnmounted(hookFn: @escaping () -> Void, identifier: String = #function) {
    let viewIdentifier = useViewIdentifier(identifier: identifier, callStackSymbols: Thread.callStackSymbols)
    let dispatcher = useDispatcher(with: viewIdentifier)
    dispatcher.unmountdHook = hookFn
}
