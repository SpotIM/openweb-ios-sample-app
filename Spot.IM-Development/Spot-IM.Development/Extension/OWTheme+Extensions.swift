//
//  OWTheme+Extensions.swift
//  Spot-IM.Development
//
//  Created by  Nogah Melamed on 03/01/2024.
//  Copyright © 2024 Spot.IM. All rights reserved.
//

import Foundation
import SpotImCore
import UIKit

extension OWTheme: Codable {
    enum CodingKeys: String, CodingKey {
        case skeletonColor
        case skeletonShimmeringColor
        case primarySeparatorColor
        case secondarySeparatorColor
        case tertiarySeparatorColor
        case primaryTextColor
        case secondaryTextColor
        case tertiaryTextColor
        case primaryBackgroundColor
        case secondaryBackgroundColor
        case tertiaryBackgroundColor
        case primaryBorderColor
        case secondaryBorderColor
        case loaderColor
        case brandColor
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.init(
            skeletonColor: try? values.decode(OWColor?.self, forKey: .skeletonColor),
            skeletonShimmeringColor: try? values.decode(OWColor?.self, forKey: .skeletonShimmeringColor),
            primarySeparatorColor: try? values.decode(OWColor?.self, forKey: .primarySeparatorColor),
            secondarySeparatorColor: try? values.decode(OWColor?.self, forKey: .secondarySeparatorColor),
            tertiarySeparatorColor: try? values.decode(OWColor?.self, forKey: .tertiarySeparatorColor),
            primaryTextColor: try? values.decode(OWColor?.self, forKey: .primaryTextColor),
            secondaryTextColor: try? values.decode(OWColor?.self, forKey: .secondaryTextColor),
            tertiaryTextColor: try? values.decode(OWColor?.self, forKey: .tertiaryTextColor),
            primaryBackgroundColor: try? values.decode(OWColor?.self, forKey: .primaryBackgroundColor),
            secondaryBackgroundColor: try? values.decode(OWColor?.self, forKey: .secondaryBackgroundColor),
            tertiaryBackgroundColor: try? values.decode(OWColor?.self, forKey: .tertiaryBackgroundColor),
            primaryBorderColor: try? values.decode(OWColor?.self, forKey: .primaryBorderColor),
            secondaryBorderColor: try? values.decode(OWColor?.self, forKey: .secondaryBorderColor),
            loaderColor: try? values.decode(OWColor?.self, forKey: .loaderColor),
            brandColor: try? values.decode(OWColor?.self, forKey: .brandColor))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(skeletonColor, forKey: .skeletonColor)
        try container.encode(skeletonShimmeringColor, forKey: .skeletonShimmeringColor)
        try container.encode(primarySeparatorColor, forKey: .primarySeparatorColor)
        try container.encode(secondarySeparatorColor, forKey: .secondarySeparatorColor)
        try container.encode(tertiarySeparatorColor, forKey: .tertiarySeparatorColor)
        try container.encode(primaryTextColor, forKey: .primaryTextColor)
        try container.encode(secondaryTextColor, forKey: .secondaryTextColor)
        try container.encode(tertiaryTextColor, forKey: .tertiaryTextColor)
        try container.encode(primaryBackgroundColor, forKey: .primaryBackgroundColor)
        try container.encode(secondaryBackgroundColor, forKey: .secondaryBackgroundColor)
        try container.encode(tertiaryBackgroundColor, forKey: .tertiaryBackgroundColor)
        try container.encode(primaryBorderColor, forKey: .primaryBorderColor)
        try container.encode(secondaryBorderColor, forKey: .secondaryBorderColor)
        try container.encode(loaderColor, forKey: .loaderColor)
        try container.encode(brandColor, forKey: .brandColor)
    }
}

extension OWColor: Codable {
    enum CodingKeys: String, CodingKey {
        case lightColor
        case darkColor
    }

    public init(from decoder: Decoder) throws {
        var container = try? decoder.container(keyedBy: CodingKeys.self)

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
