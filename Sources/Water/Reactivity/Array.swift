//
//  Array.swift
//  Water
//

import Foundation

public class ReactiveArray<T>: RandomAccessCollection, ExpressibleByArrayLiteral {
    public typealias Element = T

    private var _array: [T]
    private var effects: [any Effectable] = []

    public required init() {
        _array = []
    }

    public init(array: [T]) {
        _array = array
    }

    public required init(arrayLiteral elements: Element...) {
        _array = elements
    }

    public var array: [T] {
        get {
            trackArrayEffects()
            return _array
        }
        set {
            _array = newValue
            triggerArrayEffects()
        }
    }

    public subscript(index: Int) -> T {
        get {
//            print("get index = \(index)")
            return array[index]
        }
        set {
//            print("set value index = \(index) with new value = \(newValue)")
            replaceSubrange(index ..< index + 1, with: [newValue])
            array[index] = newValue
        }
    }

    // MARK: - Getter

    public func makeIterator() -> Array<T>.Iterator {
        return array.makeIterator()
    }

    public var startIndex: Int {
        return array.startIndex
    }

    public var endIndex: Int {
        return array.endIndex
    }

    public func index(after index: Int) -> Int {
        return array.index(after: index)
    }

    public var isEmpty: Bool {
        return array.isEmpty
    }

    public var count: Int {
        return array.count
    }

    // MARK: - Settter

    public func append(contentsOf newElements: [T]) {
        insert(contentsOf: newElements, at: _array.count)
    }

    public func append(_ newElement: T) {
        replaceSubrange(_array.count ..< _array.count, with: [newElement])
    }

    public func insert(_ newElement: T, at index: Int) {
        replaceSubrange(index ..< index, with: [newElement])
    }

    public func insert(contentsOf newElements: [T], at index: Int) {
        replaceSubrange(index ..< index, with: newElements)
    }

    @discardableResult
    public func remove(at index: Int) -> T {
        let element = _array[index]
        replaceSubrange(index ..< index + 1, with: [])
        return element
    }

    public func removeFirst(_ n: Int) {
        replaceSubrange(0 ..< n, with: [])
    }

    @discardableResult
    public func removeFirst() -> T {
        let element = _array[0]
        replaceSubrange(0 ..< 1, with: [])
        return element
    }

    public func removeLast(_ n: Int) {
        replaceSubrange((_array.count - n) ..< _array.count, with: [])
    }

    @discardableResult
    public func removeLast() -> T {
        let element = _array[_array.count - 1]
        replaceSubrange(_array.count - 1 ..< _array.count, with: [])
        return element
    }
    
    public func remove(atOffsets offsets: IndexSet) {
       for offset in offsets.reversed() {
           remove(at: offset)
       }
   }

    public func removeAll() {
        replaceSubrange(0 ..< _array.count, with: [])
    }

    public func replace(with array: [T]) {
        self.array = array
    }

    public func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C: Collection, C.Iterator.Element == T {
        array.replaceSubrange(subrange, with: newElements)
    }

    private func compare(lhs: T, rhs: T) -> Bool {
        match(lhs: lhs, rhs: rhs)
    }
    
    public func unwrap() -> [T] {
        return _array
    }
}

// MARK: - Array Extensions

extension ReactiveArray where T == String {
    func joined(separator: String = "") -> String {
        return array.joined(separator: separator)
    }
}

// MARK: - effect

extension ReactiveArray: Reactor {
    func trackArrayEffects() {
        track(reactor: self)
    }

    func triggerArrayEffects() {
        trigger(reactor: self)
    }
}

// MARK: - watch

var watchedArrays: [[Any]] = .init()

extension ReactiveArray: Watchable {
    public func watch() -> [T] {
        let array = self.array
        watchedArrays.append(array) // FIXME: - why need to store watched array
        return array
    }
}

// MARK: - def

public func defReactive<T>(_ array: [T]) -> ReactiveArray<T> {
    let observableArray = ReactiveArray(array: array)
    return observableArray
}
