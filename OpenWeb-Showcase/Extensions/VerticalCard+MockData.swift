//
//  VerticalCard+MockData.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 05/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import Foundation

extension VerticalCardData {
    var article: ArticleData {
        switch self {
        case .news: MockArticles.news()
        case .finance: MockArticles.finance()
        case .recipes: MockArticles.recipes()
        case .sport: MockArticles.sport()
        case .video: MockArticles.video()
        case .sideRail: MockArticles.sideRail()
        }
    }

    var implementationInfo: ImplementationInfo {
        switch self {
        case .news: MockImplementationInfo.news()
        case .finance: MockImplementationInfo.finance()
        case .recipes: MockImplementationInfo.recipes()
        case .sport: MockImplementationInfo.sport()
        case .video: MockImplementationInfo.video()
        case .sideRail: MockImplementationInfo.sideRail()
        }
    }
}
