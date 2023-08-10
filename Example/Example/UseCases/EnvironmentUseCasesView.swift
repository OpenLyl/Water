//
//  EnvironmentUseCasesView.swift
//  Example
//

import SwiftUI
import Water

struct EnvironmentNavigationView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("main navigation view")
                NavigationLink(destination: EnvironmentUseCasesView()) {
                    Text("use dismiss environment")
                }
            }
        }
    }
}

struct EnvironmentUseCasesView: View {
    var body: some View {
//        EnvironmentOfficalView()
//        EnvironmentBridgeView()
//        EnvironmentGlobalView()
//        EnvironmentViewModifierView()
//        UseEnvironmentView()
//        EnvironmentEditModeView()
        EnvironmentUseEditModeView()
    }
}

struct EnvironmentOfficalView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var count = 0

    var body: some View {
        let _ = Self._printChanges()
        VStack {
            Text("new value = \(count)")
            Button("+1") {
                count += 1
            }
            Button("-1") {
                count -= 1
            }
            Button("dismiss") {
                dismiss()
            }
        }
    }
}

struct EnvironmentBridgeView: View {
    private let dismissEnv = Environment(\.dismiss)
    
    var dismiss: DismissAction {
        dismissEnv.wrappedValue
    }
    
    @State private var count = 0

    var body: some View {
        VStack {
            Text("new value = \(count)")
            Button("+1") {
                count += 1
            }
            Button("-1") {
                count -= 1
            }
            Button("dismiss") {
                dismiss()
            }
        }
    }
}

// this way has performance issues
var globalEnvironmentValues: EnvironmentValues = .init()

struct EnvironmentGlobalView: View {
    @Environment(\.self) var environmentValues
    
    @State private var count = 0
    
    var body: some View {
        globalEnvironmentValues = environmentValues
        
        return VStack {
            Text("new value = \(count)")
            Button("+1") {
                count += 1
            }
            Button("-1") {
                count -= 1
            }
            Button("dismiss") {
                let dismiss = globalEnvironmentValues[keyPath: \.dismiss]
                dismiss()
            }
        }
    }
}

// A more efficient way to register and use environment
struct EnvironmentViewModifierView: View {
    @State private var count = 0
    
    var body: some View {
        let _ = Self._printChanges()
        VStack {
            Text("new value = \(count)")
            Button("+1") {
                count += 1
            }
            Button("-1") {
                count -= 1
            }
            Button("dismiss") {
                findEnvironment(keyPath: \.dismiss)?()
            }
        }
        .registerEnvironment(\EnvironmentValues.dismiss)
    }
}

struct UseEnvironmentViewModifier<Value>: ViewModifier {
    private let keyPath: KeyPath<EnvironmentValues, Value>
    private let environment: Environment<Value>
    
    init(keyPath: KeyPath<EnvironmentValues, Value>) {
        self.keyPath = keyPath
        environment = Environment(keyPath)
    }
    
    func body(content: Content) -> some View {
        keyPathEnvironments[keyPath] = self.environment
        return content
            .background(Color.clear)
    }
}

var keyPathEnvironments: [AnyKeyPath: Any] = [:]

func findEnvironment<Value>(keyPath: KeyPath<EnvironmentValues, Value>) -> Value? {
    if let environment = keyPathEnvironments[keyPath] as? Environment<Value> {
        return environment.wrappedValue
    }
    return nil
}

extension View {
    func registerEnvironment<Value>(_ keypath: KeyPath<EnvironmentValues, Value>) -> some View {
        modifier(UseEnvironmentViewModifier(keyPath: keypath))
    }
}

func UseEnvironmentView() -> some View {
    let dismiss = useEnvironment(\.dismiss)
    let count = defValue(0)
    
    return View {
        VStack {
            Text("new value = \(count.value)")
            Button("+1") {
                count.value += 1
            }
            Button("-1") {
                count.value -= 1
            }
            Button("dismiss") {
                dismiss.value?()
            }
        }
    }
    .useEnvironment(\.dismiss)
}

struct EnvironmentEditModeView: View {
    @Environment(\.editMode) var editMode
    
    @State var name = "hello word edit mode"
    
    var body: some View {
        let _ = Self._printChanges()
        Form {
            if editMode?.wrappedValue.isEditing == true {
                TextField("Name", text: $name)
            } else {
                Text(name)
            }
        }
        .animation(nil, value: editMode?.wrappedValue)
        .toolbar { // Assumes embedding this view in a NavigationView.
            EditButton()
        }
    }
}

func EnvironmentUseEditModeView() -> some View {
    let name = defValue("hello word edit mode")
    let editMode = defValue(EditMode.inactive)
    
    return View {
        Form {
            if editMode.value.isEditing == true {
                TextField("Name", text: name.bindable)
            } else {
                Text(name.value)
            }
        }
        .animation(nil, value: editMode.value)
        .toolbar {
            EditButton()
        }
        .environment(\.editMode, editMode.bindable)
    }
}
