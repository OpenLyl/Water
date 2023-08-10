//
//  CallStackIdentifier.swift
//  Water
//

import Foundation

let maxDepth = 5

func useViewIdentifier(identifier: String, callStackSymbols: [String]) -> String {
    if checkIdentifier(identifier: identifier) {
        return identifier
    } else {
        let recursiveIdentifier = findViewIdentifier(from: callStackSymbols)
        return recursiveIdentifier
    }
}

func findViewIdentifier(from callStackSymbols: [String]) -> String {
    var identifier: String? = nil
    var depth = 0
    for symbol in callStackSymbols {
        if depth >= maxDepth {
            break
        }
        let parsedStack = CallStackParser.parse(stackSymbol: symbol, includeImmediateParentClass: true) // FIXME: - parse identifier problem
        if let parsedStack = parsedStack {
            let (_, method) = parsedStack
            if checkIdentifier(identifier: method) {
                identifier = method
                break
            }
        }
        depth += 1
    }
    guard let identifier else {
        fatalError("view identifier not found, can't generate dispatcher")
    }
    return identifier
}

func checkIdentifier(identifier: String) -> Bool {
    let identifierLast2Char = identifier.suffix(2)
    return String(identifierLast2Char) == "()"
}
