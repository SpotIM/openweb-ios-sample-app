//
//  OWTheme+Properties.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 24/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import UIKit
import OpenWebSDK

extension OWTheme {
    static let properties: [(keyPath: WritableKeyPath<OWTheme, UIColor?>, name: String)] = [
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
