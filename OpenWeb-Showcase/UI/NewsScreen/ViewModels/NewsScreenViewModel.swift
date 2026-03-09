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
    var article: ArticleData { SampleArticles.news() }
    var implementationInfo: SDKUsageInfo { MockSDKUsageInfo.news() }
    var conversationArticle: OWArticleProtocol {
        OWArticle(articleInformationStrategy: .server, additionalSettings: OWArticleSettings())
    }

    func initialize() {
        OpenWeb.manager.spotId = article.spotId
        let uiColor = UIColor(VerticalCardData.news.color)
        OpenWeb.manager.ui.customizations.customizedTheme.brandColor = OWColor(lightColor: uiColor, darkColor: uiColor)
    }
}
