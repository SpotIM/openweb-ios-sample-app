//
//  UIColor+Extensions.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 22/01/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit

extension UIColor {
    // swiftlint:disable:next identifier_name
    convenience init(r: UInt32, g: UInt32, b: UInt32) {
        // swiftlint:disable:next no_magic_numbers
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: 1)
    }
}
