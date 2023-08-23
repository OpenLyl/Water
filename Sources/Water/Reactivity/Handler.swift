//
//  Handler.swift
//  Water
//

import Foundation

let mutableHandler = ReactiveHandler()
let readonlyHandler = ReactiveHandler(isReadonly: true)

struct ReactiveHandler {
    let isReadonly: Bool
    
    init(isReadonly: Bool = false) {
        self.isReadonly = isReadonly
    }
}

// MARK: - Value

extension ReactiveHandler {
    func handleGetValue<T>(_ reactiveValue: ReactiveValue<T>) -> T {
        reactiveValue.trackEffects()
        return reactiveValue._value
    }
    
    func handleSetValue<T>(_ reactiveValue: ReactiveValue<T>, _ newValue: T) {
        if sameValue(lhs: reactiveValue._value, rhs: newValue) {
            return
        }
        reactiveValue._value = newValue
        reactiveValue.triggerEffects()
    }
}

// MARK: - Object

extension ReactiveHandler {
    func handleGetTarget<T>(_ reactiveObject: ReactiveObject<T>) -> T {
        reactiveObject.trackEffects()
        return reactiveObject._target
    }
    
    func handleSetTarget<T>(_ reactiveObject: ReactiveObject<T>, _ newValue: T) {
        // FIXME: - handle readonly
        if isClass(reactiveObject._target),
           isClass(newValue),
           samePointer(lhs: reactiveObject._target, rhs: newValue)
        {
            return
        }
        
        if isStruct(reactiveObject._target),
           isStruct(newValue),
           sameValue(lhs: reactiveObject._target, rhs: newValue) {
            return
        }
        
        reactiveObject._target = newValue
        reactiveObject.triggerEffects()
    }
}

// MARK: - Array

extension ReactiveHandler {
    func handleGetArray<T>(_ reactiveArray: ReactiveArray<T>) -> [T] {
        reactiveArray.trackEffects()
        return reactiveArray._array
    }
    
    func handleSetArray<T>(_ reactiveArray: ReactiveArray<T>, _ newValue: [T]) {
        assert(!isReadonly, "set new array failed because it's readonly") // FIXME: - check use readonly
        
        // FIXME: - array is same, need compare ?
        reactiveArray._array = newValue
        reactiveArray.triggerEffects()
    }
}

extension ReactiveHandler {
    func handleGetProperty<T, V>(of reactiveObject: ReactiveObject<T>, at keyPath: KeyPath<T, V>) -> V {
        if (!isReadonly) {
            reactiveObject.trackEffects(at: keyPath)
        }
        return reactiveObject._target[keyPath: keyPath]
    }
    
    func handleSetProperty<T, V>(of reactiveObject: ReactiveObject<T>, at keyPath: KeyPath<T, V>, with newValue: V) {
        assert(!isReadonly, "set property at keyPath: \(keyPath) failed, becase \(reactiveObject._target) is readonly")
        
        guard let keyPath = keyPath as? WritableKeyPath<T, V> else {
            assertionFailure("set value: \(newValue) at keyPath: \(keyPath) failed, maybe define your property use 'var' not 'let'")
            return
        }
        
        let oldValue = reactiveObject._target[keyPath: keyPath]
        if sameValue(lhs: oldValue, rhs: newValue) {
            return
        }
        reactiveObject._target[keyPath: keyPath] = newValue
        reactiveObject.triggerEffects(at: keyPath)
    }
}
