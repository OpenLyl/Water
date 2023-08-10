//
//  Watch.swift
//  Water
//

import Foundation

// TODO: - add watch mode
// TODO: - watch support multiple source
// TODO: - support onCleanup
// TODO: - use swift 5.9 repeat watch multiple sources

public typealias WatchCleanup = (_ cleanupFn: @escaping () -> Void) -> Void
public typealias WatchEffectFn = (_ onCleanup: WatchCleanup) -> Void
public typealias WatchCallback<T> = (_ value: T, _ oldValue: T, _ onCleanup: WatchCleanup) -> Void
public typealias WatchTracker<T> = () -> T
public typealias WatchStopHandle = () -> Void

public protocol Watchable {
    associatedtype W
    func watch() -> W
}

@discardableResult
public func defWatchEffect(_ effectClosure: @escaping WatchEffectFn) -> WatchStopHandle {
    var effect: ReactiveEffect<()>!
    var cleanup: () -> Void = { }
    
    func onCleanup(_ cleanupFn: @escaping () -> Void) {
        cleanup = {
            cleanupFn()
        }
        effect.onStop = cleanup
    }
    
    func watchGetter() {
        cleanup()
        effectClosure(onCleanup)
    }
    
    effect = ReactiveEffect(watchGetter)
    effect.run(track: true)
    
    let unwatch = {
        effect.stop()
    }
    
    return unwatch
}

@discardableResult
public func defWatch<T, Source: Watchable>(_ source: Source, onChange watchCallback: @escaping WatchCallback<T>) -> WatchStopHandle where Source.W == T {
    defWatch({ source.watch() }, onChange: watchCallback)
}

@discardableResult
public func defWatch<T, V>(_ source: ReactiveObject<T>, at keyPath: WritableKeyPath<T, V>, onChange watchCallback: @escaping WatchCallback<V>) -> WatchStopHandle {
    defWatch({
        source.trackPropertyEffects(keyPath)
        return source.target[keyPath: keyPath]
    }, onChange: watchCallback)
}

@discardableResult
public func defWatch<T>(_ watchTrackClosure: @escaping WatchTracker<T>, onChange watchCallback: @escaping WatchCallback<T>) -> WatchStopHandle {
    var oldValue: T!
    var newValue: T!
    var effect: ReactiveEffect<T>!
    var cleanup: () -> Void = { }
    
    func onCleanup(_ cleanupFn: @escaping () -> Void) {
        cleanup = {
            cleanupFn()
        }
        effect.onStop = cleanup
    }
    
    // effect
    func watchGetter() -> T {
        return watchTrackClosure()
    }
    
    // scheduler
    func watchScheduler() {
        doJob()
    }
  
    // scheduler job
    func doJob() {
        newValue = effect.run()
        cleanup()
        // FIXME: - compare state
        watchCallback(newValue, oldValue, onCleanup)
        oldValue = newValue
    }
    
    effect = ReactiveEffect(watchGetter, watchScheduler)

    oldValue = effect.run(track: true)
    
    let unwatch = {
        effect.stop()
    }
    
    return unwatch
}

// MARK: - watch two sources

public typealias WatchTwoCallback<A, B> = (_ values: (A, B), _ oldValues: (A, B)) -> Void

public func defWatch<A, B, SourceA: Watchable, SourceB: Watchable>
(
    _ sources: (SourceA, SourceB),
    onChange watchCallbackClosure: @escaping WatchTwoCallback<A, B>
)
where SourceA.W == A, SourceB.W == B
{
    var oldValues: (A, B)!
    var newValues: (A, B)!
    var effect: ReactiveEffect<(A, B)>!
    
    // effect
    func watchGetter() -> (A, B) {
        let a = sources.0.watch()
        let b = sources.1.watch()
        return (a, b)
    }
    
    // scheduler
    func watchScheduler() {
        doJob()
    }
    
    effect = ReactiveEffect(watchGetter, watchScheduler)
    
    // scheduler job
    func doJob() {
        newValues = effect.run()
        // FIXME: - compare state
        watchCallbackClosure(newValues, oldValues)
//        oldValues = newValues // FIXME: - mutiple source change only trigger callback once use dispatch queue main async
    }
    
    oldValues = effect.run(track: true)
}

public func defWatchable<T, V>(_ source: ReactiveObject<T>, at keyPath: WritableKeyPath<T, V>) -> PropertyWatcher<T, V> {
    return .init(source: source, keyPath: keyPath)
}

public func defWatchable<T>(_ watchTrackClosure: @escaping WatchTracker<T>) -> PropertyWatchTrackClosureWrapper<T> {
    return .init(watchTrackClosure: watchTrackClosure)
}
