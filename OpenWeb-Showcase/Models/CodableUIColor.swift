//
//  CodableUIColor.swift
//  OpenWeb-Development
//
//  Created by  Nogah Melamed on 03/01/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import OpenWebSDK
import UIKit

/// Codable wrapper for UIColor serialization
struct CodableUIColor: Codable, Equatable {
    var lightColor: ColorComponents
    var darkColor: ColorComponents

    init(from color: UIColor) {
        lightColor = ColorComponents(from: color.lightColor)
        darkColor = ColorComponents(from: color.darkColor)
    }

    func toUIColor() -> UIColor {
        UIColor(lightColor: lightColor.toUIColor(), darkColor: darkColor.toUIColor())
    }

    struct ColorComponents: Codable, Equatable {
        var red: CGFloat
        var green: CGFloat
        var blue: CGFloat
        var alpha: CGFloat

        init(from color: UIColor) {
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            self.red = red
            self.green = green
            self.blue = blue
            self.alpha = alpha
        }

        func toUIColor() -> UIColor {
            return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
    }
}
