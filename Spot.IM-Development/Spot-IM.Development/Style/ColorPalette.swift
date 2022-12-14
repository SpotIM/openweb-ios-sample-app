//
//  ColorPalette.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 10/05/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

// Internal colors inside the SampleApp.
// Should be changed once we have a design for the internal app which will eventually become public, but for now some nice colors

class ColorPalette {
    static var blue = UIColor(r: 0, g: 161, b: 229)
    static var blackish = UIColor(r: 51, g: 51, b: 51)
    static var darkGrey = UIColor(r: 128, g: 128, b: 128)
    static var basicGrey = UIColor(r: 196, g: 196, b: 196)
    static var midGrey = UIColor(r: 225, g: 225, b: 225)
    static var lightGrey = UIColor(r: 241, g: 241, b: 241)
    static var extraLightGrey = UIColor(r: 247, g: 247, b: 247)
    static var red = UIColor(r: 228, g: 66, b: 88)
    static var orange = UIColor(r: 255, g: 172, b: 44)
    static var green = UIColor(r: 0, g: 202, b: 114)
    static var purple = UIColor(r: 163, g: 88, b: 223)
    static var pink = UIColor(r: 246, g: 95, b: 124)
    static var highlightBlue = UIColor(r: 204, g: 233, b: 255)
    static var white = UIColor(r: 255, g: 255, b: 255)
}

fileprivate extension UIColor {
    convenience init(r: UInt32, g: UInt32, b: UInt32) {
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: 1)
    }
}
