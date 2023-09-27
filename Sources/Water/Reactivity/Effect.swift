//
//  Effect.swift
//  Water
//

// TODO: - global store watch effect
// TODO: - debugger display all effects with target

import OSLog

// MARK: - global Variables

var activeEffect: AnyEffect?

var shouldTrack: Bool = false
var canTrack: Bool {
    shouldTrack && activeEffect != nil
}

// MARK: - types

public typealias Scheduler = () -> Void
public typealias OnStop = () -> Void
public typealias AnyEffect = any Effectable
typealias AnyReactor = any Reactor

public protocol Effectable: AnyObject {
    associatedtype T

    @discardableResult
    func run(track: Bool) -> T
    func beforeRun() -> Bool
    func afterRun(_ lastShouldTrack: Bool)
    
    func stop()

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
    private var parent: AnyEffect? = nil

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
    
    public func stop() {
        stop(with: nil)
    }

    func stop(with target: AnyReactor? = nil) {
        if !isActive {
            return
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
        effect.run(track: false)
    }

    func stop(with target: AnyReactor? = nil) {
        effect.stop(with: target)
    }
}

public func stop<T>(_ runner: ReactiveEffectRunner<T>) {
    runner.stop()
}

// MARK: - reactor

public func isDefined(_ value: Any) -> Bool {
    return value is Reactor
}

protocol Reactor: AnyObject {
    func trackEffects()
    func triggerEffects()
    func trackEffects(at keyPath: AnyKeyPath)
    func triggerEffects(at keyPath: AnyKeyPath)
}

// FIXME: - this default implements abstract from ReactiveObject, need reconsider
extension Reactor {
    func trackEffects() {
        track(reactor: self)
    }

    func triggerEffects() {
        trigger(reactor: self)
        // TODO: - need trigger watch effect
    }

    func trackEffects(at keyPath: AnyKeyPath) {
        track(reactor: self, at: keyPath)
    }

    func triggerEffects(at keyPath: AnyKeyPath) {
        trigger(reactor: self, at: keyPath)
        trigger(reactor: self) // also trigger the watch effect
    }
}

func trackEffects(_ effects: inout [AnyEffect]) -> Bool {
    guard canTrack else {
        return false
    }
    guard let currentEffect = activeEffect else {
        return false
    }
    if effects.contains(where: { $0 === currentEffect }) {
        return false
    }
    effects.append(currentEffect)
    return true
    //FIXME: - add track with effect, given effect an identifier
//    print("current effect = \(MemoryAddress(of: (currentEffect as AnyObject)).description) tracked, total effects = \(effects.count)")
}

// FIXME: - fix the effects not clear problem
func triggerEffects(_ effects: [AnyEffect]) {
//    print("trigger effects count = \(effects.count)")
    if effects.count == 0 {
        print("trigger effects is empty")
    }
    for effect in effects {
        if let scheduler = effect.scheduler {
            scheduler()
        } else {
//            print("trigger effect = \(MemoryAddress(of: (effect as AnyObject)).description)")
            effect.run(track: false)
        }
    }
}

// MARK: - track and trigger effect

// reactor -> [effect]
struct ReactorEffectMap {
    let reactor: AnyReactor
    var effects: [AnyEffect] = []
}

// reactor.keypath -> [effect]
struct ReactorKeyPathEffectMap {
    let reactor: AnyReactor
    let keyPath: AnyKeyPath
    var effects: [AnyEffect] = []
}

// FIXME: - need refactor this data structure
var globalEffects: [ReactorEffectMap] = []
var globalKeyPathEffects: [ReactorKeyPathEffectMap] = []

func track(reactor: AnyReactor) {
    var currentReactorMap: ReactorEffectMap

    let index = globalEffects.firstIndex { $0.reactor === reactor }
    if let index {
        currentReactorMap = globalEffects[index]
    } else {
        currentReactorMap = ReactorEffectMap(reactor: reactor)
    }

    var currentReactorEffects = currentReactorMap.effects
    let trackSucceed = trackEffects(&currentReactorEffects)
    
    // if not track the effect, not need update
    guard trackSucceed else {
        return
    }
    
    currentReactorMap.effects = currentReactorEffects
    if let index {
        globalEffects[index] = currentReactorMap
    } else {
        globalEffects.append(currentReactorMap)
    }
    
//    displayGlobalEffects()
}

func trigger(reactor: AnyReactor) {
    guard let currentReactorMap = globalEffects.filter({ $0.reactor === reactor }).first else {
        print("current reactor has tracked no effects.")
        return
    }
    let currentReactorEffects = currentReactorMap.effects
    triggerEffects(currentReactorEffects)
}

func track(reactor: AnyReactor, at keyPath: AnyKeyPath) {
    var currentReactorKeyPathMap: ReactorKeyPathEffectMap

    let index = globalKeyPathEffects.firstIndex { $0.reactor === reactor && $0.keyPath === keyPath }
    if let index {
        currentReactorKeyPathMap = globalKeyPathEffects[index]
    } else {
        currentReactorKeyPathMap = ReactorKeyPathEffectMap(reactor: reactor, keyPath: keyPath)
    }

    var currentReactorKeyPathEffects = currentReactorKeyPathMap.effects
    let trackSucceed = trackEffects(&currentReactorKeyPathEffects)
    
    // if not track the effect, not need update
    guard trackSucceed else {
        return
    }

    currentReactorKeyPathMap.effects = currentReactorKeyPathEffects

    if let index {
        globalKeyPathEffects[index] = currentReactorKeyPathMap
    } else {
        globalKeyPathEffects.append(currentReactorKeyPathMap)
    }
    
    displayKeyPathEffects()
}

func trigger(reactor: AnyReactor, at keyPath: AnyKeyPath) {
    guard let currentTargetKeyPathMap = globalKeyPathEffects.filter({ $0.reactor === reactor && $0.keyPath === keyPath }).first else {
        return
    }
    let currentTargetKeyPathEffects = currentTargetKeyPathMap.effects
    triggerEffects(currentTargetKeyPathEffects)
}

// MARK: - cleanup Effects

func cleanupEffect(_ effect: AnyEffect, with target: AnyReactor? = nil) {
    if let target { // clean by target point
        if let index = globalEffects.firstIndex(where: { $0.reactor === target }) {
            cleanupGlobalEffects(effect: effect, at: index)
        } else if let index = globalKeyPathEffects.firstIndex(where: { $0.reactor === target }) {
            cleanupGlobalKeyPathEffects(effect: effect, at: index)
        }
    } else { // clean by effect point
        // clean up from global target effects
        while (true) {
            if let index = globalEffects.firstIndex(where: { $0.effects.contains { $0 === effect } }) {
                cleanupGlobalEffects(effect: effect, at: index)
            } else {
                break
            }
        }
        
        // clean up from global target keypath effects
        while (true) {
            if let index = globalKeyPathEffects.firstIndex(where: { $0.effects.contains { $0 === effect } }) {
                cleanupGlobalKeyPathEffects(effect: effect, at: index)
            } else {
                break
            }
        }
    }
}

func cleanupGlobalEffects(effect: AnyEffect, at index: Int) {
    var reactorMap = globalEffects[index]
    var reactorEffects = reactorMap.effects
    reactorEffects.removeAll { $0 === effect }
    if reactorEffects.count == 0 {
        globalEffects.remove(at: index)
    } else {
        reactorMap.effects = reactorEffects
        globalEffects[index] = reactorMap
    }
}

func cleanupGlobalKeyPathEffects(effect: AnyEffect, at index: Int) {
    var reactorKeyPathMap = globalKeyPathEffects[index]
    var reactorKeyPathEffects = reactorKeyPathMap.effects
    reactorKeyPathEffects.removeAll { $0 === effect }
    if reactorKeyPathEffects.count == 0 {
        globalKeyPathEffects.remove(at: index)
    } else {
        reactorKeyPathMap.effects = reactorKeyPathEffects
        globalKeyPathEffects[index] = reactorKeyPathMap
    }
}

// FIXME: - cleanup effect use target and keypath

// MARK: - monitor effect

let logger = Logger(subsystem: "Water", category: "effects")

func displayAllEffects() {
    if globalEffects.count > 0 {
        displayGlobalEffects()
        logger.debug("\n")
    }
    if globalKeyPathEffects.count > 0 {
        displayKeyPathEffects()
        logger.debug("\n")
    }
}

func displayGlobalEffects() {
    logger.debug("<- global effects [\(globalEffects.count)] ->")
    for effectMap in globalEffects {
        let reactor = effectMap.reactor
        let effects = effectMap.effects
        logger.debug("  [current reactor = \(MemoryAddress(of: reactor as AnyObject).description)] - effects [\(effects.count)]")
        for effect in effects {
            logger.debug("      effect = \(MemoryAddress(of: effect as AnyObject).description)")
        }
    }
    logger.debug("<- global effects ->")
}

func displayKeyPathEffects() {
    logger.debug("<- global keyPath effects [\(globalKeyPathEffects.count)] ->")
    for keyPathEffectMap in globalKeyPathEffects {
        let reactor = keyPathEffectMap.reactor
//        let keyPath = keyPathEffectMap.keyPath - FIXME: - display keyPath
        let effects = keyPathEffectMap.effects
        logger.debug("<- current reactor = \(MemoryAddress(of: reactor as AnyObject).description) at keyPath - effects [\(effects.count)] ->")
        for effect in effects {
            logger.debug("<- effect = \(MemoryAddress(of: effect as AnyObject).description) ->")
        }
    }
    logger.debug("<- global keyPath effects ->")
}
