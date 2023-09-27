//
//  useEnvironment.swift
//  Water
//

import SwiftUI

// MARK: - def

public func useEnvironment<Value>(_ keyPath: KeyPath<EnvironmentValues, Value>, identifier: String = #function) -> EnvironmentValue<Value> {
    let viewIdentifier = useViewIdentifier(identifier: identifier, callStackSymbols: Thread.callStackSymbols)
    return EnvironmentValue(keyPath: keyPath, identifier: viewIdentifier)
}

public class EnvironmentValue<Value> {
    private let keyPath: KeyPath<EnvironmentValues, Value>
    private let identifier: String

    init(keyPath: KeyPath<EnvironmentValues, Value>, identifier: String) {
        self.keyPath = keyPath
        self.identifier = identifier
    }

    public var value: Value? {
        let dispatcher = useDispatcher(with: identifier)
        let keyPathEnvironments = dispatcher.keyPathEnvironments
        if let environment = keyPathEnvironments[keyPath] as? Environment<Value> {
            return environment.wrappedValue
        } else {
            return nil
        }
    }
}

// MARK: - use

struct UseEnvironmentViewModifier<Value>: ViewModifier {
    private let keyPath: KeyPath<EnvironmentValues, Value>
    private var dispatcher: Dispatcher

    private let environment: Environment<Value> // dynamic inject by system

    init(keyPath: KeyPath<EnvironmentValues, Value>, dispatcher: Dispatcher) {
        self.keyPath = keyPath
        self.dispatcher = dispatcher
        environment = Environment(keyPath)
    }

    func body(content: Content) -> some View {
        dispatcher.keyPathEnvironments[keyPath] = environment
        return content.background(Color.clear)
    }
}

public extension ContainerView {
    func useEnvironment<Value>(_ keyPath: KeyPath<EnvironmentValues, Value>) -> some View {
        let dispatcher = useDispatcher(with: identifier) // FIXME: - get dispatcher by identifier ?
        return modifier(UseEnvironmentViewModifier(keyPath: keyPath, dispatcher: dispatcher)) // FIXME: - fix the warning, accessing state object without be installed
    }
}
