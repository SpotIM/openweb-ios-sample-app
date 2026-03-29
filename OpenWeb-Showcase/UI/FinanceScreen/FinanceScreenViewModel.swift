//
//  FinanceScreenViewModel.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 11/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import OpenWebSDK
import Combine

class FinanceScreenViewModel: ObservableObject {
    private let vertical: ShowcaseVertical = .finance

    var article: ArticleData { vertical.article }
    var sdkUsageInfo: SDKUsageInfo { vertical.sdkUsageInfo }
    var color: Color { vertical.color }
    var title: LocalizedStringResource { vertical.title }
    @Published var articleSettings: OWArticleProtocol = OWArticle()
    @Published var screenSettings = SettingsManager.shared.additionalSettings

    init() {
        articleSettings = getArticleSettings()
    }

    func initialize() {
        articleSettings = getArticleSettings()
        screenSettings = SettingsManager.shared.additionalSettings
        // MARK: OpenWeb SDK
        OpenWeb.manager.spotId = article.spotId
        OpenWeb.manager.ui.customizations.customizedTheme.brandColor = OWColor(color)
        ShowcaseScreenConfigurator.applyShowcaseSettings()
    }
}

private extension FinanceScreenViewModel {
    func getArticleSettings() -> OWArticleProtocol {
        var settingsArticle = SettingsManager.shared.article
        let settings = OWArticleSettings(
            section: "stock",
            headerStyle: settingsArticle.additionalSettings.headerStyle,
            readOnlyMode: settingsArticle.additionalSettings.readOnlyMode,
            starRatingEnabled: settingsArticle.additionalSettings.starRatingEnabled
        )
        settingsArticle.additionalSettings = settings
        return settingsArticle
    }
}
