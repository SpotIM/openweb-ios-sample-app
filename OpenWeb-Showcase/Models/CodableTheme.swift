//
//  CodableTheme.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 24/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import OpenWebSDK

struct CodableTheme: Codable, Equatable {
    var skeletonColor: CodableUIColor?
    var skeletonShimmeringColor: CodableUIColor?
    var primarySeparatorColor: CodableUIColor?
    var secondarySeparatorColor: CodableUIColor?
    var tertiarySeparatorColor: CodableUIColor?
    var primaryTextColor: CodableUIColor?
    var secondaryTextColor: CodableUIColor?
    var tertiaryTextColor: CodableUIColor?
    var primaryBackgroundColor: CodableUIColor?
    var secondaryBackgroundColor: CodableUIColor?
    var tertiaryBackgroundColor: CodableUIColor?
    var surfaceColor: CodableUIColor?
    var primaryBorderColor: CodableUIColor?
    var secondaryBorderColor: CodableUIColor?
    var loaderColor: CodableUIColor?
    var brandColor: CodableUIColor?
    var voteUpUnselectedColor: CodableUIColor?
    var voteDownUnselectedColor: CodableUIColor?
    var voteUpSelectedColor: CodableUIColor?
    var voteDownSelectedColor: CodableUIColor?

    var owTheme: OWTheme {
        OWTheme(
            skeletonColor: skeletonColor?.toUIColor(),
            skeletonShimmeringColor: skeletonShimmeringColor?.toUIColor(),
            primarySeparatorColor: primarySeparatorColor?.toUIColor(),
            secondarySeparatorColor: secondarySeparatorColor?.toUIColor(),
            tertiarySeparatorColor: tertiarySeparatorColor?.toUIColor(),
            primaryTextColor: primaryTextColor?.toUIColor(),
            secondaryTextColor: secondaryTextColor?.toUIColor(),
            tertiaryTextColor: tertiaryTextColor?.toUIColor(),
            primaryBackgroundColor: primaryBackgroundColor?.toUIColor(),
            secondaryBackgroundColor: secondaryBackgroundColor?.toUIColor(),
            tertiaryBackgroundColor: tertiaryBackgroundColor?.toUIColor(),
            surfaceColor: surfaceColor?.toUIColor(),
            primaryBorderColor: primaryBorderColor?.toUIColor(),
            secondaryBorderColor: secondaryBorderColor?.toUIColor(),
            loaderColor: loaderColor?.toUIColor(),
            brandColor: brandColor?.toUIColor(),
            voteUpUnselectedColor: voteUpUnselectedColor?.toUIColor(),
            voteDownUnselectedColor: voteDownUnselectedColor?.toUIColor(),
            voteUpSelectedColor: voteUpSelectedColor?.toUIColor(),
            voteDownSelectedColor: voteDownSelectedColor?.toUIColor()
        )
    }

    static let properties: [(keyPath: WritableKeyPath<CodableTheme, CodableUIColor?>, name: String)] = [
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
