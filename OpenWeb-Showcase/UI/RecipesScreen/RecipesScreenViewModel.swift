//
//  RecipesScreenViewModel.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 11/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import OpenWebSDK
import Combine

class RecipesScreenViewModel: ObservableObject {
    private let vertical: ShowcaseVertical = .recipes

    var article: ArticleData { vertical.article }
    var sdkUsageInfo: SDKUsageInfo { vertical.sdkUsageInfo }
    var color: Color { vertical.color }
    var title: LocalizedStringResource { vertical.title }
    @Published var articleSettings = SettingsStore.shared.article
    @Published var screenSettings = SettingsStore.shared.additionalSettings

    init() {
        // MARK: OpenWeb SDK
        OpenWeb.manager.spotId = article.spotId
    }

    func initialize() {
        articleSettings = SettingsStore.shared.article
        screenSettings = SettingsStore.shared.additionalSettings

        ShowcaseScreenConfigurator.applyShowcaseSettings()
        if nil == OpenWeb.manager.ui.customizations.elements.brand.color {
            // MARK: OpenWeb SDK
            OpenWeb.manager.ui.customizations.elements.brand.color = UIColor(color)
        }
    }
}
