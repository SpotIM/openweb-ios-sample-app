//
//  OWColor+Extensions.swift
//  Spot-IM.Development
//
//  Created by  Nogah Melamed on 03/01/2024.
//  Copyright © 2024 Spot.IM. All rights reserved.
//

import Foundation
import SpotImCore
import UIKit

extension OWColor: Codable {
    enum CodingKeys: String, CodingKey {
        case lightColor
        case darkColor
    }

    public init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)

        let lightColorComponents = try container?.decode(ColorComponents.self, forKey: .lightColor)
        let darkColorComponents = try container?.decode(ColorComponents.self, forKey: .darkColor)

        self.init(lightColor: lightColorComponents?.toUIColor() ?? UIColor(),
                  darkColor: darkColorComponents?.toUIColor() ?? UIColor())
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let lightColorComponents = ColorComponents(from: self.lightColor)
        let darkColorComponents = ColorComponents(from: self.darkColor)
        try container.encode(lightColorComponents, forKey: .lightColor)
        try container.encode(darkColorComponents, forKey: .darkColor)
    }

    fileprivate struct ColorComponents: Codable {
        let red: CGFloat
        let green: CGFloat
        let blue: CGFloat
        let alpha: CGFloat

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
