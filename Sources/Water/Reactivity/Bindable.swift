//
//  SwiftUIExt.swift
//  Water
//

import SwiftUI

extension ReactiveValue {
    public var bindable: Binding<T> {
        Binding {
            self.value
        } set: { newValue, transaction in
            withTransaction(transaction) {
                self.value = newValue
            }
        }
    }
}

extension ComputedValue {
    public var bindable: Binding<T> {
        Binding {
            self.value
        } set: { newValue, transaction in
            withTransaction(transaction) {
                self.value = newValue
            }
        }
    }
}

extension ReactiveObject {
    public var bindable: Binding<T> {
        Binding {
            self.target
        } set: { newValue, transaction in
            withTransaction(transaction) {
                self.target = newValue
            }
        }
    }
}

extension ReactiveArray {
    public var bindable: Binding<[T]> {
        Binding {
            self.array
        } set: { newValue, transaction in
            withTransaction(transaction) {
                self.array = newValue
            }
        }
    }
}
