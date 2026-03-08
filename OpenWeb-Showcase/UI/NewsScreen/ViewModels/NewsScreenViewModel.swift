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
    private let vertical: VerticalCardData = .news

    var article: ArticleData { vertical.article }
    var implementationInfo: ImplementationInfo { vertical.implementationInfo }
    var conversationArticle: OWArticleProtocol {
        OWArticle(articleInformationStrategy: .server, additionalSettings: OWArticleSettings())
    }

    func initialize() {
        OpenWeb.manager.spotId = article.conversationIds.spotId
        let uiColor = UIColor(vertical.color)
        OpenWeb.manager.ui.customizations.customizedTheme.brandColor = OWColor(lightColor: uiColor, darkColor: uiColor)
    }
}
