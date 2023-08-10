//
//  Effect.swift
//  Water
//

// TODO: - global store watch effect
// TODO: - debugger display all effects with target

// MARK: - global Variables

var activeEffect: (any Effectable)?

var shouldTrack: Bool = false
var canTrack: Bool {
    shouldTrack && activeEffect != nil
}

// MARK: - types

public typealias Scheduler = () -> Void
public typealias OnStop = () -> Void

public protocol Effectable: AnyObject {
    associatedtype T
    
    @discardableResult
    func run(track: Bool) -> T
    func beforeRun() -> Bool
    func afterRun(_ lastShouldTrack: Bool)
    
    var scheduler: Scheduler? { get }
}
 
// MARK: - def

@discardableResult
public func defEffect<T>(_ effectClosure: @escaping () -> T, scheduler: Scheduler? = nil, onStop: OnStop? = nil) -> ReactiveEffectRunner<T> {
    let effect = ReactiveEffect(effectClosure, scheduler, onStop)
    effect.run(track: true)
    
    let runner = ReactiveEffectRunner(effect: effect)
    return runner
}

// MARK: - effect

public class ReactiveEffect<T>: Effectable {
    private let fn: () -> T
    
    public var scheduler: Scheduler?
    var onStop: OnStop?
    
    private var isActive = true
    private var parent: (any Effectable)? = nil

    init(_ fn: @escaping () -> T, _ scheduler: Scheduler? = nil, _ onStop: OnStop? = nil) {
        self.fn = fn
        self.scheduler = scheduler
        self.onStop = onStop
    }

    deinit {
//        print("reactive effect deinit")
    }
    
    // TODO: - log track depth
    @discardableResult
    public func run(track: Bool = false) -> T {
        if !track {
            let lastShouldTrack = shouldTrack
            shouldTrack = false
            
            let res = fn()
            
            shouldTrack = lastShouldTrack
            return res
        }
        
        if !isActive {
            return fn()
        }

        let lastShouldTrack = beforeRun()
        let res = fn() // collect dependency effects
        afterRun(lastShouldTrack)

        return res
    }
    
    func stop(with target: (any Reactor)? = nil) {
        if !isActive {
            return;
        }
        cleanupEffect(self, with: target)
        onStop?()
        isActive = false
    }
    
    // FIXME: - can reuse the code with not track
    public func beforeRun() -> Bool {
        let lastShouldTrack = shouldTrack
        parent = activeEffect
        activeEffect = self
        shouldTrack = true
        return lastShouldTrack
    }
    
    public func afterRun(_ lastShouldTrack: Bool) {
        activeEffect = parent
        shouldTrack = lastShouldTrack
        parent = nil
    }
}

// MARK: - runner and stop

public struct ReactiveEffectRunner<T> {
    let effect: ReactiveEffect<T>
    
    func run() -> T {
        return effect.run(track: false)
    }
    
    func stop(with target: (any Reactor)? = nil) {
        effect.stop(with: target)
    }
}

public func stop<T>(_ runner: ReactiveEffectRunner<T>) {
    runner.stop()
}

public func stop<T>(_ reactor: any Reactor, _ runner: ReactiveEffectRunner<T>) {
    runner.stop(with: reactor)
}

// MARK: - track and trigger reactor

public protocol Reactor: AnyObject {
    
}

func trackEffects(_ effects: inout [any Effectable]) {
    guard canTrack else {
        return
    }
    guard let currentEffect = activeEffect else {
        return
    }
    if effects.contains(where: { $0 === currentEffect }) {
        return
    }
    effects.append(currentEffect)
}

func triggerEffects(_ effects: [any Effectable]) {
    for effect in effects {
        if let scheduler = effect.scheduler {
            scheduler()
        } else {
            effect.run(track: false)
        }
    }
}

struct ReactorEffectMap {
    let reactor: any Reactor
    var effects: [any Effectable] = []
}

struct ReactorKeyPathEffectMap {
    let reactor: any Reactor
    let keyPath: AnyKeyPath
    var effects: [any Effectable] = []
}

var globalEffects: [ReactorEffectMap] = []
var globalKeyPathEffects: [ReactorKeyPathEffectMap] = []

func track(reactor: any Reactor) {
    var currentReactorMap: ReactorEffectMap
    
    let index = globalEffects.firstIndex { $0.reactor === reactor }
    if let index {
        currentReactorMap = globalEffects[index]
    } else {
        currentReactorMap = ReactorEffectMap(reactor: reactor)
    }
    
    var currentReactorEffects = currentReactorMap.effects
    trackEffects(&currentReactorEffects)
    
    currentReactorMap.effects = currentReactorEffects
    
    if let index {
        globalEffects[index] = currentReactorMap
    } else {
        globalEffects.append(currentReactorMap)
    }
}

func trigger(reactor: any Reactor) {
    guard let currentReactorMap = globalEffects.filter({ $0.reactor === reactor }).first else {
        return
    }
    let currentReactorEffects = currentReactorMap.effects
    triggerEffects(currentReactorEffects)
}

func track(reactor: any Reactor, at keyPath: AnyKeyPath) {
    var currentReactorKeyPathMap: ReactorKeyPathEffectMap
    
    let index = globalKeyPathEffects.firstIndex { $0.reactor === reactor && $0.keyPath === keyPath }
    if let index {
        currentReactorKeyPathMap = globalKeyPathEffects[index]
    } else {
        currentReactorKeyPathMap = ReactorKeyPathEffectMap(reactor: reactor, keyPath: keyPath)
    }
    
    var currentReactorKeyPathEffects = currentReactorKeyPathMap.effects
    trackEffects(&currentReactorKeyPathEffects)
    
    currentReactorKeyPathMap.effects = currentReactorKeyPathEffects
    
    if let index {
        globalKeyPathEffects[index] = currentReactorKeyPathMap
    } else {
        globalKeyPathEffects.append(currentReactorKeyPathMap)
    }
}

func trigger(reactor: any Reactor, at keyPath: AnyKeyPath) {
    guard let currentTargetKeyPathMap = globalKeyPathEffects.filter({ $0.reactor === reactor && $0.keyPath === keyPath}).first else {
        return
    }
    let currentTargetKeyPathEffects = currentTargetKeyPathMap.effects
    triggerEffects(currentTargetKeyPathEffects)
}

func cleanupEffect(_ effect: any Effectable, with target: (any Reactor)? = nil) {
    if let target {
        if let index = globalEffects.firstIndex(where: {$0.reactor === target }) {
            cleanupGlobalEffects(effect: effect, at: index)
        } else if let index = globalKeyPathEffects.firstIndex(where: { $0.reactor === target }) {
            cleanupGlobalKeyPathEffects(effect: effect, at: index)
        }
    } else {
        // clean up from global target effects
        if let index = globalEffects.firstIndex(where: { $0.effects.contains{ $0 === effect} }) {
            cleanupGlobalEffects(effect: effect, at: index)
        }
        
        // clean up from global target keypath effects
        if let index = globalKeyPathEffects.firstIndex(where: { $0.effects.contains{ $0 === effect } }) {
            cleanupGlobalKeyPathEffects(effect: effect, at: index)
        }
    }
}

func cleanupGlobalEffects(effect: any Effectable, at index: Int) {
    var reactorMap = globalEffects[index]
    var reactorEffects = reactorMap.effects
    reactorEffects.removeAll { $0 === effect }
    reactorMap.effects = reactorEffects
    globalEffects[index] = reactorMap
}

func cleanupGlobalKeyPathEffects(effect: any Effectable, at index: Int) {
    var reactorKeyPathMap = globalKeyPathEffects[index]
    var reactorKeyPathEffects = reactorKeyPathMap.effects
    reactorKeyPathEffects.removeAll { $0 === effect }
    reactorKeyPathMap.effects = reactorKeyPathEffects
    globalKeyPathEffects[index] = reactorKeyPathMap
}
