//
//  UIColor+Extensions.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 22/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(r: UInt32, g: UInt32, b: UInt32) {
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: 1)
    }
}
