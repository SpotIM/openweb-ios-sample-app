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
        switch index {
        case OWArticleInformationStrategy.server.index:
            return .server
        case OWArticleInformationStrategy.local(data: OWArticleExtraData.empty).index:
            let article = OWArticle.stub()
            return article.articleInformationStrategy
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
