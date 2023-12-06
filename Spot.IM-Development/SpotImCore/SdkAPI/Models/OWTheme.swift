//
//  OWTheme.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 05/12/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

public struct OWTheme {
    public let skeletonColor: OWColor?
    public let skeletonShimmeringColor: OWColor?
    public let primarySeparatorColor: OWColor?
    public let secondarySeparatorColor: OWColor?
    public let tertiarySeparatorColor: OWColor?
    public let primaryTextColor: OWColor?
    public let secondaryTextColor: OWColor?
    public let tertiaryTextColor: OWColor?
    public let primaryBackgroundColor: OWColor?
    public let secondaryBackgroundColor: OWColor?
    public let tertiaryBackgroundColor: OWColor?
    public let primaryBorderColor: OWColor?
    public let secondaryBorderColor: OWColor?
    public let loaderColor: OWColor?
    public let brandColor: OWColor?

    public init(skeletonColor: OWColor? = nil,
                skeletonShimmeringColor: OWColor? = nil,
                primarySeparatorColor: OWColor? = nil,
                secondarySeparatorColor: OWColor? = nil,
                tertiarySeparatorColor: OWColor? = nil,
                primaryTextColor: OWColor? = nil,
                secondaryTextColor: OWColor? = nil,
                tertiaryTextColor: OWColor? = nil,
                primaryBackgroundColor: OWColor? = nil,
                secondaryBackgroundColor: OWColor? = nil,
                tertiaryBackgroundColor: OWColor? = nil,
                primaryBorderColor: OWColor? = nil,
                secondaryBorderColor: OWColor? = nil,
                loaderColor: OWColor? = nil,
                brandColor: OWColor? = nil
    ) {
        self.skeletonColor = skeletonColor
        self.skeletonShimmeringColor = skeletonShimmeringColor
        self.primarySeparatorColor = primarySeparatorColor
        self.secondarySeparatorColor = secondarySeparatorColor
        self.tertiarySeparatorColor = tertiarySeparatorColor
        self.primaryTextColor = primaryTextColor
        self.secondaryTextColor = secondaryTextColor
        self.tertiaryTextColor = tertiaryTextColor
        self.primaryBackgroundColor = primaryBackgroundColor
        self.secondaryBackgroundColor = secondaryBackgroundColor
        self.tertiaryBackgroundColor = tertiaryBackgroundColor
        self.primaryBorderColor = primaryBorderColor
        self.secondaryBorderColor = secondaryBorderColor
        self.loaderColor = loaderColor
        self.brandColor = brandColor
    }
}
