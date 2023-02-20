//
//  OWArticle.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public struct OWArticle: OWArticleProtocol {
    public let url: URL
    public let title: String
    public let subtitle: String?
    public let thumbnailUrl: URL?
    public let additionalSettings: OWArticleSettingsProtocol

    public init(url: URL,
                title: String,
                subtitle: String? = nil,
                thumbnailUrl: URL? = nil,
                additionalSettings: OWArticleSettingsProtocol) {
        self.url = url
        self.title = title
        self.subtitle = subtitle
        self.thumbnailUrl = thumbnailUrl
        self.additionalSettings = additionalSettings
    }
}
#else
struct OWArticle: OWArticleProtocol {
    let url: URL
    let title: String
    let subtitle: String?
    let thumbnailUrl: URL?
    let additionalSettings: OWArticleSettingsProtocol
}
#endif
