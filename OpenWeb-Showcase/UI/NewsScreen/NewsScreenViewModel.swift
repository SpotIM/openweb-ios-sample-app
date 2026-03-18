//
//  NewsScreenViewModel.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 02/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import OpenWebSDK
import Combine

class NewsScreenViewModel: ObservableObject {
    private let vertical: ShowcaseVertical = .news

    var article: ArticleData { vertical.article }
    var sdkUsageInfo: SDKUsageInfo { vertical.sdkUsageInfo }
    var color: Color { vertical.color }
    var title: LocalizedStringResource { vertical.title }
    @Published var articleSettings = SettingsManager.shared.article
    @Published var screenSettings = SettingsManager.shared.additionalSettings

    func initialize() {
        articleSettings = SettingsManager.shared.article
        screenSettings = SettingsManager.shared.additionalSettings
        // MARK: OpenWeb SDK
        OpenWeb.manager.spotId = article.spotId
        OpenWeb.manager.ui.customizations.customizedTheme.brandColor = OWColor(color)
    }
}
