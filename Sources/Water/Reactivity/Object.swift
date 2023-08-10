//
//  Object.swift
//  Water
//

import Foundation

@dynamicMemberLookup
public class ReactiveObject<T> {
    private var _target: T
    private var effects: [AnyKeyPath: [any Effectable]] = [:]
    private var watchEffects: [any Effectable] = []
    
    public var target: T {
        get {
            if checkObjectIsClass(_target) {
                trackObjectEffects()
            }
            return _target
        }
        set {
            if checkObjectIsClass(_target) {
                if sameObject(lhs: _target, rhs: newValue) {
                    return
                }
                _target = newValue
                triggerObjectEffects()
            } else {
                _target = newValue
            }
        }
    }

    init(target: T) {
        self._target = target
    }

    deinit {
//        print("deinit reactive object, value = \(target)")
    }
    
    public subscript<V>(dynamicMember keyPath: WritableKeyPath<T, V>) -> V {
        get {
            print("get keyPath \(keyPath)")
            trackPropertyEffects(keyPath)
            return target[keyPath: keyPath]
        }
        set {
            print("set keyPath \(keyPath)")
            let oldValue = target[keyPath: keyPath]
            if match(lhs: oldValue, rhs: newValue) {
                return
            }
            target[keyPath: keyPath] = newValue
            triggerPropertyEffects(keyPath)
        }
    }
    
    public func unwrap() -> T {
        return target
    }
}

// MARK: - effect

extension ReactiveObject: Reactor {
    func trackObjectEffects() {
        track(reactor: self)
    }
    
    func triggerObjectEffects() {
        trigger(reactor: self)
        // TODO: - need trigger watch effect
    }
    
    func trackPropertyEffects(_ keyPath: AnyKeyPath) {
        track(reactor: self, at: keyPath)
    }

    func triggerPropertyEffects(_ keyPath: AnyKeyPath) {
        trigger(reactor: self, at: keyPath)
        trigger(reactor: self) // also trigger the watch effect
    }
}

// MARK: - watch

public struct PropertyWatcher<T, V>: Watchable {
    let source: ReactiveObject<T>
    let keyPath: WritableKeyPath<T, V>
    
    public func watch() -> V {
        source.trackPropertyEffects(keyPath)
        return source.target[keyPath: keyPath]
    }
}

public struct PropertyWatchTrackClosureWrapper<T>: Watchable {
    let watchTrackClosure: WatchTracker<T>
    
    public func watch() -> T {
        return watchTrackClosure()
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
    let reactive = ReactiveObject(target: target)
    return reactive
}
