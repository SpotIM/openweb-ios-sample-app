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
    var conversationArticle: OWArticleProtocol {
        OWArticle(articleInformationStrategy: .server, additionalSettings: OWArticleSettings())
    }

    func initialize() {
        OpenWeb.manager.spotId = article.spotId
        let uiColor = UIColor(color)
        OpenWeb.manager.ui.customizations.customizedTheme.brandColor = OWColor(lightColor: uiColor, darkColor: uiColor)
    }
}
