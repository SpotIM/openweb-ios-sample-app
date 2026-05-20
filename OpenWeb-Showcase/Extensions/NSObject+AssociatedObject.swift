//
//  NSObject+AssociatedObject.swift
//  OpenWebSDK
//
//  Created by Yonat Sharon on 01/10/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation

// See https://github.com/atrick/swift-evolution/blob/diagnose-implicit-raw-bitwise/proposals/nnnn-implicit-raw-bitwise-conversion.md#associated-object-string-keys
extension NSObject {
    /// `objc_getAssociatedObject()` without warnings
    func getObjectiveCAssociatedObject<T>(key: inout String) -> T? {
        withUnsafePointer(to: &key) {
            return objc_getAssociatedObject(self, $0) as? T
        }
    }

    /// `objc_setAssociatedObject()` without warnings
    func setObjectiveCAssociatedObject<T>(key: inout String, value: T?) {
        withUnsafePointer(to: &key) {
            objc_setAssociatedObject(self, $0, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
