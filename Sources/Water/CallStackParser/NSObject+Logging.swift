//
//  NSObject+Logging.swift
//  GDXRepo
//
//  Created by Georgiy Malyukov on 26.05.2018.
//  Copyright © 2022 Georgiy Malyukov. All rights reserved.
//

import Foundation

extension NSObject {
    
    var fullTypename: String {
        NSStringFromClass(type(of: self))
    }
    
    var shortTypename: String {
        fullTypename.replacingOccurrences(of: "^[^\\.]+\\.", with: "", options: .regularExpression, range: nil)
    }
    
    func d(_ string: String) {
        let dt = Date().description

        for symbol in Thread.callStackSymbols[1...] {
            if let parsed = CallStackParser.parse(stackSymbol: symbol) {
                print("\(dt) [\(parsed.0)] \(parsed.1) \(string)")
                return
            }
        }
        print("\(dt) [\(shortTypename)] \(string)")
    }
}
