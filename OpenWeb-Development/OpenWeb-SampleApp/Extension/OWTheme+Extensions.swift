//
//  OWTheme+Extensions.swift
//  OpenWeb-Development
//
//  Created by  Nogah Melamed on 03/01/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import OpenWebSDK

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
        case surfaceColor
        case primaryBorderColor
        case secondaryBorderColor
        case loaderColor
        case brandColor
        case voteUpColor
        case voteDownColor
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
            surfaceColor: try? values.decode(OWColor?.self, forKey: .surfaceColor),
            primaryBorderColor: try? values.decode(OWColor?.self, forKey: .primaryBorderColor),
            secondaryBorderColor: try? values.decode(OWColor?.self, forKey: .secondaryBorderColor),
            loaderColor: try? values.decode(OWColor?.self, forKey: .loaderColor),
            brandColor: try? values.decode(OWColor?.self, forKey: .brandColor),
            voteUpColor: try? values.decode(OWColor?.self, forKey: .voteUpColor),
            voteDownColor: try? values.decode(OWColor?.self, forKey: .voteDownColor))
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
        try container.encode(surfaceColor, forKey: .surfaceColor)
        try container.encode(primaryBorderColor, forKey: .primaryBorderColor)
        try container.encode(secondaryBorderColor, forKey: .secondaryBorderColor)
        try container.encode(loaderColor, forKey: .loaderColor)
        try container.encode(brandColor, forKey: .brandColor)
        try container.encode(voteUpColor, forKey: .voteUpColor)
        try container.encode(voteDownColor, forKey: .voteDownColor)
    }
}
