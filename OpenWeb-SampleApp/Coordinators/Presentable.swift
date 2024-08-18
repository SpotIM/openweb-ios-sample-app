//
//  Presentable.swift
//  OpenWeb-iOS-SDK-Demo
//
//  Created by Alon Haiut on 29/11/2021.
//

import Foundation
import UIKit

public protocol Presentable {
    func toPresentable() -> UIViewController
}

extension UIViewController: Presentable {
    public func toPresentable() -> UIViewController {
        return self
    }
}
