//
//  NewsScreenViewModel.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 02/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import OpenWebSDK

@Observable
class NewsScreenViewModel {
    private let vertical: VerticalCard = .news

    var article: ArticleData { vertical.article }
    var implementationInfo: ImplementationInfo { vertical.implementationInfo }

    func initialize() {
        OpenWeb.manager.spotId = article.conversationIds.spotId
    }
}
