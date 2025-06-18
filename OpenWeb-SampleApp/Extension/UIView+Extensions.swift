//
//  UIView+Extensions.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 21/06/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit
import Foundation

extension UIView {
    var firstResponder: UIView? {
        guard !isFirstResponder else { return self }
        for subview in subviews {
            if let firstResponder = subview.firstResponder {
                return firstResponder
            }
        }
        return nil
    }

    var isVisible: Bool {
        guard let window else { return false }
        let frameInWindowCoordinates = convert(bounds, to: window)
        let intersection = frameInWindowCoordinates.intersection(window.bounds)
        return !intersection.isEmpty
    }
}
