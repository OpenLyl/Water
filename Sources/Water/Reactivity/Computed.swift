//
//  Computed.swift
//  Water
//

import Foundation

public typealias ComputedGetter<T> = () -> T
public typealias ComputedSetter<T> = (T) -> Void

public class ComputedValue<T> {
    private var _value: T!
    
    private var effect: ReactiveEffect<T>!
    private var dirty = true
    private let setter: ComputedSetter<T>?

    public init(getter: @escaping ComputedGetter<T>, setter: ComputedSetter<T>?) {
        self.setter = setter
        effect = ReactiveEffect(getter,  {
            if (self.dirty) {
                return
            }
            self.dirty = true
            self.triggerComputedEffects()
        })
    }

    public var value: T {
        get {
            trackComputedEffects()
            if (dirty) {
                dirty = false
                _value = effect.run(track: true) // custom track effects upper codes
            }
            return _value
        }
        set {
            setter?(newValue)
        }
    }
}

extension ComputedValue: Reactor {
    func trackComputedEffects() {
        track(reactor: self)
    }
    
    func triggerComputedEffects() {
        trigger(reactor: self)
    }
}

// MARK: - def

public func defComputed<T>(_ getter: @escaping ComputedGetter<T>, setter: ComputedSetter<T>? = nil) -> ComputedValue<T> {
    let computedValue = ComputedValue(getter: getter, setter: setter)
    return computedValue
}
