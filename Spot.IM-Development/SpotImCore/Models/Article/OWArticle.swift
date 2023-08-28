//
//  OWArticle.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public class OWArticle: OWArticleProtocol {
    public var url: URL
    public var title: String
    public var subtitle: String?
    public var thumbnailUrl: URL?
    public let articleInformationStrategy: OWArticleInformationStrategy
    public let additionalSettings: OWArticleSettingsProtocol

    public init(articleInformationStrategy: OWArticleInformationStrategy,
//        url: URL,
//                title: String,
//                subtitle: String? = nil,
//                thumbnailUrl: URL? = nil,
                additionalSettings: OWArticleSettingsProtocol) {
        self.url = articleInformationStrategy.url
        self.title = articleInformationStrategy.title
        self.subtitle = articleInformationStrategy.subtitle
        self.thumbnailUrl = articleInformationStrategy.thumbnailUrl
        self.articleInformationStrategy = articleInformationStrategy
        self.additionalSettings = additionalSettings
    }

    // Update data according to server if needed
    internal func onConversationRead(extractData: SPConversationExtraDataRM?) {
        guard case .server = articleInformationStrategy,
              let extractData = extractData
        else { return }

        if let url = extractData.url {
            self.url = url
        }
        self.title = extractData.title ?? ""
        self.subtitle = extractData.description
        self.thumbnailUrl = extractData.thumbnailUrl
    }
}
#else
class OWArticle: OWArticleProtocol {
    var url: URL
    var title: String
    var subtitle: String?
    var thumbnailUrl: URL?
    let articleInformationStrategy: OWArticleInformationStrategy
    let additionalSettings: OWArticleSettingsProtocol

    public init(articleInformationStrategy: OWArticleInformationStrategy,
                additionalSettings: OWArticleSettingsProtocol) {
        self.url = articleInformationStrategy.url
        self.title = articleInformationStrategy.title
        self.subtitle = articleInformationStrategy.subtitle
        self.thumbnailUrl = articleInformationStrategy.thumbnailUrl
        self.articleInformationStrategy = articleInformationStrategy
        self.additionalSettings = additionalSettings
    }

    // Update data according to server if needed
    internal func onConversationRead(extractData: SPConversationExtraDataRM?) {
        guard case .server = articleInformationStrategy,
              let extractData = extractData
        else { return }

        if let url = extractData.url {
            self.url = url
        }
        self.title = extractData.title ?? ""
        self.subtitle = extractData.description
        self.thumbnailUrl = extractData.thumbnailUrl
    }
}
#endif
