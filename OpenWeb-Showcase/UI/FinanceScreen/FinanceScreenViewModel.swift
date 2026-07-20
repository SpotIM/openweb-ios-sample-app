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
    @Published var screenSettings = SettingsStore.shared.additionalSettings

    init() {
        articleSettings = getArticleSettings()
        // MARK: OpenWeb SDK
        OpenWeb.manager.spotId = article.spotId
    }

    func initialize() {
        articleSettings = getArticleSettings()
        screenSettings = SettingsStore.shared.additionalSettings

        ShowcaseScreenConfigurator.applyShowcaseSettings()
        if nil == OpenWeb.manager.ui.customizations.elements.brand.color {
            // MARK: OpenWeb SDK
            OpenWeb.manager.ui.customizations.elements.brand.color = UIColor(color)
        }
    }
}

private extension FinanceScreenViewModel {
    func getArticleSettings() -> OWArticleProtocol {
        var settingsArticle = SettingsStore.shared.article
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
