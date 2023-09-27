//
//  ContainerView.swift
//  Water
//

import SwiftUI

public func View<Content: View>(@ViewBuilder content: @escaping () -> Content, identifier: String = #function) -> ContainerView<Content> {
    ContainerView(identifier: identifier, content: content)
}

public struct ContainerView<Content: View>: View {
    @StateObject private var dispatcher: Dispatcher // FIXME: - use ObservedObject or StateObject ?
    
    let identifier: String
    private let content: () -> Content

    init(identifier: String, @ViewBuilder content: @escaping () -> Content) {
        self.identifier = identifier
        self.content = content

        let dispatcher = useDispatcher(with: identifier) // FIXME: - 1. force find the dispatcher by identifier 2. need register stateobject to environment ?
//        dispatcher.clear() // FIXME: - write test case to test the clear and when to clear
        _dispatcher = StateObject(wrappedValue: dispatcher)
    }

    public var body: some View {
        dispatcher.clear() // FIXME: - this can move to disappear ?
        
        dispatcher.isScheduling = true
        
        let renderEffect = dispatcher.setupRenderEffect() // FIXME: - only set active effect, change it use scheduler or runner
        let lastShouldTrack = renderEffect.beforeRun()

//        print("<----------------------------")
//        print("\(identifier) - before render")
        
//        if #available(iOS 15.0, *) {
//            let _ = Self._printChanges()
//        }
        
        let content = content()

        // FIXME: - memory leaks
//        dispatcher.currentEffectCursor = 0
//        dispatcher.pendingEffects.forEach {
//            $0.resolve(by: dispatcher)
//        }

//        print("\(identifier) - after render")
//        print("---------------------------->")

        renderEffect.afterRun(lastShouldTrack)
        
        dispatcher.isScheduling = false

//        dispatcher.tryCleanupRenderEffect()
        
        return content
            .onAppear(perform: actionOnAppear)
            .onDisappear(perform: actionOnDisappear)
    }
    
    func actionOnAppear() {
        //        print("\(identifier) - on appear")
        dispatcher.mountHook?()
    }
    
    func actionOnDisappear() {
        //        print("\(identifier) - on dis appear")
        dispatcher.unmountdHook?()
    }


    // TODO: - next idea - use my own observation
//    var body: some View {
//        withObservationTracking {
//            content()
//        } onChange: {
//            stateObj.updateView()
//        }
//    }
}
