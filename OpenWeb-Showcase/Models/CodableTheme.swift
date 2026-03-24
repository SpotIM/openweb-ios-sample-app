//
//  CodableTheme.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 24/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import OpenWebSDK

struct CodableTheme: Codable, Equatable {
    var skeletonColor: CodableColor?
    var skeletonShimmeringColor: CodableColor?
    var primarySeparatorColor: CodableColor?
    var secondarySeparatorColor: CodableColor?
    var tertiarySeparatorColor: CodableColor?
    var primaryTextColor: CodableColor?
    var secondaryTextColor: CodableColor?
    var tertiaryTextColor: CodableColor?
    var primaryBackgroundColor: CodableColor?
    var secondaryBackgroundColor: CodableColor?
    var tertiaryBackgroundColor: CodableColor?
    var surfaceColor: CodableColor?
    var primaryBorderColor: CodableColor?
    var secondaryBorderColor: CodableColor?
    var loaderColor: CodableColor?
    var brandColor: CodableColor?
    var voteUpUnselectedColor: CodableColor?
    var voteDownUnselectedColor: CodableColor?
    var voteUpSelectedColor: CodableColor?
    var voteDownSelectedColor: CodableColor?

    var owTheme: OWTheme {
        OWTheme(
            skeletonColor: skeletonColor?.owColor,
            skeletonShimmeringColor: skeletonShimmeringColor?.owColor,
            primarySeparatorColor: primarySeparatorColor?.owColor,
            secondarySeparatorColor: secondarySeparatorColor?.owColor,
            tertiarySeparatorColor: tertiarySeparatorColor?.owColor,
            primaryTextColor: primaryTextColor?.owColor,
            secondaryTextColor: secondaryTextColor?.owColor,
            tertiaryTextColor: tertiaryTextColor?.owColor,
            primaryBackgroundColor: primaryBackgroundColor?.owColor,
            secondaryBackgroundColor: secondaryBackgroundColor?.owColor,
            tertiaryBackgroundColor: tertiaryBackgroundColor?.owColor,
            surfaceColor: surfaceColor?.owColor,
            primaryBorderColor: primaryBorderColor?.owColor,
            secondaryBorderColor: secondaryBorderColor?.owColor,
            loaderColor: loaderColor?.owColor,
            brandColor: brandColor?.owColor,
            voteUpUnselectedColor: voteUpUnselectedColor?.owColor,
            voteDownUnselectedColor: voteDownUnselectedColor?.owColor,
            voteUpSelectedColor: voteUpSelectedColor?.owColor,
            voteDownSelectedColor: voteDownSelectedColor?.owColor
        )
    }

    static let properties: [(keyPath: WritableKeyPath<CodableTheme, CodableColor?>, name: String)] = [
        (\.skeletonColor, "Skeleton"),
        (\.skeletonShimmeringColor, "Skeleton Shimmering"),
        (\.primarySeparatorColor, "Primary Separator"),
        (\.secondarySeparatorColor, "Secondary Separator"),
        (\.tertiarySeparatorColor, "Tertiary Separator"),
        (\.primaryTextColor, "Primary Text"),
        (\.secondaryTextColor, "Secondary Text"),
        (\.tertiaryTextColor, "Tertiary Text"),
        (\.primaryBackgroundColor, "Primary Background"),
        (\.secondaryBackgroundColor, "Secondary Background"),
        (\.tertiaryBackgroundColor, "Tertiary Background"),
        (\.surfaceColor, "Surface"),
        (\.primaryBorderColor, "Primary Border"),
        (\.secondaryBorderColor, "Secondary Border"),
        (\.loaderColor, "Loader"),
        (\.brandColor, "Brand"),
        (\.voteUpUnselectedColor, "Vote Up Unselected"),
        (\.voteDownUnselectedColor, "Vote Down Unselected"),
        (\.voteUpSelectedColor, "Vote Up Selected"),
        (\.voteDownSelectedColor, "Vote Down Selected"),
    ]
}
