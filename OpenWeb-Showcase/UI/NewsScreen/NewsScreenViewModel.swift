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
    @Published var articleSettings = SettingsStore.shared.article
    @Published var screenSettings = SettingsStore.shared.additionalSettings

    func initialize() {
        articleSettings = SettingsStore.shared.article
        screenSettings = SettingsStore.shared.additionalSettings
        // MARK: OpenWeb SDK
        OpenWeb.manager.spotId = article.spotId
        OpenWeb.manager.ui.customizations.customizedTheme.brandColor = UIColor(color)
        ShowcaseScreenConfigurator.applyShowcaseSettings()
    }
}
