//
//  OWArticleInformationStrategy+Extensions.swift
//  Spot-IM.Development
//
//  Created by  Nogah Melamed on 28/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import SpotImCore

#if NEW_API

extension OWArticleInformationStrategy {
    static func articleInformationStrategy(fromIndex index: Int) -> OWArticleInformationStrategy {
        let article = OWArticle.stub()
        switch index {
        case OWArticleInformationStrategy.server.index: return .server
        case 1: return .local(url: article.url, title: article.title, subtitle: article.subtitle, thumbnailUrl: article.thumbnailUrl) // TODO: 
        default:
            return `default`
        }
    }

    static var `default`: OWArticleInformationStrategy {
        return .server
    }

    var index: Int {
        switch self {
        case .server: return 0
        case .local: return 1
        default:
            return OWArticleInformationStrategy.`default`.index
        }
    }
}

#endif
