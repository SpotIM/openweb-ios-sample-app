//
//  OWArticle.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

public struct OWArticle: OWArticleProtocol {
    public let articleInformationStrategy: OWArticleInformationStrategy
    public let additionalSettings: OWArticleSettingsProtocol

    public init(articleInformationStrategy: OWArticleInformationStrategy,
                additionalSettings: OWArticleSettingsProtocol) {
        self.articleInformationStrategy = articleInformationStrategy
        self.additionalSettings = additionalSettings
    }
}
