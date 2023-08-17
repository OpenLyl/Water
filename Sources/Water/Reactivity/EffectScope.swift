//
//  EffectScope.swift
//  Water
//

var activeEffectScope: EffectScope? = nil

public class EffectScope {
    private let _active = true
    
    let effects: [AnyEffect] = []
    
    var parent: EffectScope? = nil
    let children: [EffectScope]? = nil
    let currentIndex: Int? = nil
    
    init(detached: Bool = false) {
        self.parent = activeEffectScope
    }
}

extension EffectScope {
    var scopes: [EffectScope] {
        children ?? []
    }
}
