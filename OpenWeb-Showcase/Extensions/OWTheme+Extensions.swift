//
//  OWTheme+Extensions.swift
//  OpenWeb-Development
//
//  Created by  Nogah Melamed on 03/01/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import OpenWebSDK

extension OWTheme: @retroactive Codable {
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
        case voteUpUnselectedColor
        case voteDownUnselectedColor
        case voteUpSelectedColor
        case voteDownSelectedColor
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.init(
            skeletonColor: (try? values.decode(CodableUIColor.self, forKey: .skeletonColor))?.toUIColor(),
            skeletonShimmeringColor: (try? values.decode(CodableUIColor.self, forKey: .skeletonShimmeringColor))?.toUIColor(),
            primarySeparatorColor: (try? values.decode(CodableUIColor.self, forKey: .primarySeparatorColor))?.toUIColor(),
            secondarySeparatorColor: (try? values.decode(CodableUIColor.self, forKey: .secondarySeparatorColor))?.toUIColor(),
            tertiarySeparatorColor: (try? values.decode(CodableUIColor.self, forKey: .tertiarySeparatorColor))?.toUIColor(),
            primaryTextColor: (try? values.decode(CodableUIColor.self, forKey: .primaryTextColor))?.toUIColor(),
            secondaryTextColor: (try? values.decode(CodableUIColor.self, forKey: .secondaryTextColor))?.toUIColor(),
            tertiaryTextColor: (try? values.decode(CodableUIColor.self, forKey: .tertiaryTextColor))?.toUIColor(),
            primaryBackgroundColor: (try? values.decode(CodableUIColor.self, forKey: .primaryBackgroundColor))?.toUIColor(),
            secondaryBackgroundColor: (try? values.decode(CodableUIColor.self, forKey: .secondaryBackgroundColor))?.toUIColor(),
            tertiaryBackgroundColor: (try? values.decode(CodableUIColor.self, forKey: .tertiaryBackgroundColor))?.toUIColor(),
            surfaceColor: (try? values.decode(CodableUIColor.self, forKey: .surfaceColor))?.toUIColor(),
            primaryBorderColor: (try? values.decode(CodableUIColor.self, forKey: .primaryBorderColor))?.toUIColor(),
            secondaryBorderColor: (try? values.decode(CodableUIColor.self, forKey: .secondaryBorderColor))?.toUIColor(),
            loaderColor: (try? values.decode(CodableUIColor.self, forKey: .loaderColor))?.toUIColor(),
            brandColor: (try? values.decode(CodableUIColor.self, forKey: .brandColor))?.toUIColor(),
            voteUpUnselectedColor: (try? values.decode(CodableUIColor.self, forKey: .voteUpUnselectedColor))?.toUIColor(),
            voteDownUnselectedColor: (try? values.decode(CodableUIColor.self, forKey: .voteDownUnselectedColor))?.toUIColor(),
            voteUpSelectedColor: (try? values.decode(CodableUIColor.self, forKey: .voteUpSelectedColor))?.toUIColor(),
            voteDownSelectedColor: (try? values.decode(CodableUIColor.self, forKey: .voteDownSelectedColor))?.toUIColor()
        )
    }

    @available(*, deprecated, message: "Silences OpenWebSDK deprecation warnings")
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(skeletonColor.map(CodableUIColor.init), forKey: .skeletonColor)
        try container.encodeIfPresent(skeletonShimmeringColor.map(CodableUIColor.init), forKey: .skeletonShimmeringColor)
        try container.encodeIfPresent(primarySeparatorColor.map(CodableUIColor.init), forKey: .primarySeparatorColor)
        try container.encodeIfPresent(secondarySeparatorColor.map(CodableUIColor.init), forKey: .secondarySeparatorColor)
        try container.encodeIfPresent(tertiarySeparatorColor.map(CodableUIColor.init), forKey: .tertiarySeparatorColor)
        try container.encodeIfPresent(primaryTextColor.map(CodableUIColor.init), forKey: .primaryTextColor)
        try container.encodeIfPresent(secondaryTextColor.map(CodableUIColor.init), forKey: .secondaryTextColor)
        try container.encodeIfPresent(tertiaryTextColor.map(CodableUIColor.init), forKey: .tertiaryTextColor)
        try container.encodeIfPresent(primaryBackgroundColor.map(CodableUIColor.init), forKey: .primaryBackgroundColor)
        try container.encodeIfPresent(secondaryBackgroundColor.map(CodableUIColor.init), forKey: .secondaryBackgroundColor)
        try container.encodeIfPresent(tertiaryBackgroundColor.map(CodableUIColor.init), forKey: .tertiaryBackgroundColor)
        try container.encodeIfPresent(surfaceColor.map(CodableUIColor.init), forKey: .surfaceColor)
        try container.encodeIfPresent(primaryBorderColor.map(CodableUIColor.init), forKey: .primaryBorderColor)
        try container.encodeIfPresent(secondaryBorderColor.map(CodableUIColor.init), forKey: .secondaryBorderColor)
        try container.encodeIfPresent(loaderColor.map(CodableUIColor.init), forKey: .loaderColor)
        try container.encodeIfPresent(brandColor.map(CodableUIColor.init), forKey: .brandColor)
        try container.encodeIfPresent(voteUpUnselectedColor.map(CodableUIColor.init), forKey: .voteUpUnselectedColor)
        try container.encodeIfPresent(voteDownUnselectedColor.map(CodableUIColor.init), forKey: .voteDownUnselectedColor)
        try container.encodeIfPresent(voteUpSelectedColor.map(CodableUIColor.init), forKey: .voteUpSelectedColor)
        try container.encodeIfPresent(voteDownSelectedColor.map(CodableUIColor.init), forKey: .voteDownSelectedColor)
    }
}
