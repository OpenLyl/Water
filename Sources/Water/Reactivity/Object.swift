//
//  Object.swift
//  Water
//

import Foundation

@dynamicMemberLookup
public class ReactiveObject<T>: Reactor {
    var _target: T
    
    private var _reactiveHandler: ReactiveHandler
    
    init(target: T, handler: ReactiveHandler) {
        _target = target
        _reactiveHandler = handler
    }
    
    public var target: T {
        get {
            _reactiveHandler.handleGetTarget(self)
        }
        set {
            _reactiveHandler.handleSetTarget(self, newValue)
        }
    }
    
    public subscript<V>(dynamicMember keyPath: KeyPath<T, V>) -> V {
        get {
//            print("get keyPath \(keyPath)")
            _reactiveHandler.handleGetProperty(of: self, at: keyPath)
        }
        set {
//            print("set keyPath \(keyPath) - new value = \(newValue)")
            if let keyPath = keyPath as? WritableKeyPath<T, V> {
                _reactiveHandler.handleSetProperty(of: self, at: keyPath, with: newValue)
            } else {
                fatalError("the key path is not writable")
            }
        }
    }
    
    public func unwrap() -> T {
        _target
    }
}

extension ReactiveObject {
    public var isReadonly: Bool {
        _reactiveHandler.isReadonly
    }
    
    public var isReactive: Bool {
        !_reactiveHandler.isReadonly
    }
}

// MARK: - watch

public struct PropertyWatcher<T, V>: Watchable {
    let source: ReactiveObject<T>
    let keyPath: WritableKeyPath<T, V>

    public func watch() -> V {
        source.trackEffects(at: keyPath) // only track effect with keypath
        return source._target[keyPath: keyPath]
    }
}

public struct PropertyWatchTrackClosureWrapper<T>: Watchable {
    let watchTrackClosure: WatchTracker<T>

    public func watch() -> T {
        watchTrackClosure()
    }
}

extension ReactiveObject: Watchable {
    public func watch() -> T {
        track(reactor: self)
        return target
    }
}

// MARK: - def

public func defReactive<T>(_ target: T) -> ReactiveObject<T> {
    createReactiveObject(target, mutableHandler)
}

public func defReadonly<T>(_ target: T) -> ReactiveObject<T> {
    createReactiveObject(target, readonlyHandler)
}

func createReactiveObject<T>(_ target: T, _ handler: ReactiveHandler) -> ReactiveObject<T> {
    ReactiveObject(target: target, handler: handler)
}
