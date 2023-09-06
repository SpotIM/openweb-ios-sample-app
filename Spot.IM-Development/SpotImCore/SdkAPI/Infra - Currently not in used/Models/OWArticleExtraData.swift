//
//  OWArticleExtraData.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 29/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public struct OWArticleExtraData: Codable {
    public let url: URL
    public let title: String
    public let subtitle: String?
    public let thumbnailUrl: URL?

    public init(url: URL, title: String, subtitle: String?, thumbnailUrl: URL?) {
        self.url = url
        self.title = title
        self.subtitle = subtitle
        self.thumbnailUrl = thumbnailUrl
    }
}

#else
struct OWArticleExtraData: Codable {
    let url: URL
    let title: String
    let subtitle: String?
    let thumbnailUrl: URL?

    init(url: URL, title: String, subtitle: String?, thumbnailUrl: URL?) {
        self.url = url
        self.title = title
        self.subtitle = subtitle
        self.thumbnailUrl = thumbnailUrl
    }
}
#endif
