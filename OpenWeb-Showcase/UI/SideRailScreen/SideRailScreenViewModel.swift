//
//  SideRailScreenViewModel.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 11/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import OpenWebSDK
import Combine

class SideRailScreenViewModel: ObservableObject {
    private let vertical: ShowcaseVertical = .sideRail

    var article: ArticleData { vertical.article }
    var sdkUsageInfo: SDKUsageInfo { vertical.sdkUsageInfo }
    var color: Color { vertical.color }
    var title: LocalizedStringResource { vertical.title }

    func initialize() {
        // MARK: OpenWeb SDK
        OpenWeb.manager.spotId = article.spotId
        OpenWeb.manager.ui.customizations.customizedTheme.brandColor = OWColor(color)
    }
}
