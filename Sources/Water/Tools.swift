//
//  Tools.swift
//  Water
//

import Foundation

func assertMainThread(file: StaticString = #file, line: UInt = #line) {
    assert(Thread.isMainThread, "This API must be called only on the main thread.", file: file, line: line)
}

// MARK: - Equatable

func isEqual<T: Equatable>(type: T.Type, a: Any, b: Any) -> Bool {
    guard let a = a as? T, let b = b as? T else { return false }
    return a == b
}

func areEqual(first: Any, second: Any) -> Bool {
    guard
        let equatableOne = first as? any Equatable,
        let equatableTwo = second as? any Equatable
    else { return false }

    return equatableOne.isEqual(equatableTwo)
}

// FIXME: - change the name of ==
public func sameValue<L, R>(lhs: L, rhs: R) -> Bool {
    guard
        let equatableLhs = lhs as? any Equatable,
        let equatableRhs = rhs as? any Equatable
    else { return false }

    return equatableLhs.isEqual(equatableRhs)
}

public func samePointer<L, R>(lhs: L, rhs: R) -> Bool {
    let objectLhs = lhs as AnyObject
    let objectRhs = rhs as AnyObject
    return objectLhs === objectRhs
}

extension Equatable {
    func isEqual(_ other: any Equatable) -> Bool {
        guard let other = other as? Self else {
            return other.isExactlyEqual(self)
        }
        return self == other
    }

    private func isExactlyEqual(_ other: any Equatable) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self == other
    }
}

struct MemoryAddress<T>: CustomStringConvertible {
    let intValue: Int

    var description: String {
        let length = 2 + 2 * MemoryLayout<UnsafeRawPointer>.size
        return String(format: "%0\(length)p", intValue)
    }

    // for structures
    init(of structPointer: UnsafePointer<T>) {
        intValue = Int(bitPattern: structPointer)
    }
}

extension MemoryAddress where T: AnyObject {
    // for classes
    init(of classInstance: T) {
        intValue = unsafeBitCast(classInstance, to: Int.self)
        // or      Int(bitPattern: Unmanaged<T>.passUnretained(classInstance).toOpaque())
    }
}

func isClass<T>(_ object: T) -> Bool {
    Mirror(reflecting: object).displayStyle == .class
}

func isStruct<T>(_ object: T) -> Bool {
    Mirror(reflecting: object).displayStyle == .struct
}