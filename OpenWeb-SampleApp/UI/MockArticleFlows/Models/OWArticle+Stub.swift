//
//  OWArticle+Stub.swift
//  OpenWeb-Development
//
//  Created by Alon Haiut on 07/09/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
import OpenWebSDK

extension OWArticle {
    static func stub() -> OWArticle {
        let url = "https://test.com"
        let imageUrl = "https://53.fs1.hubspotusercontent-na1.net/hub/53/hubfs/parts-url.jpg?width=595&height=400&name=parts-url.jpg"
        let title = "This is a placeholder for the article title. The container is limited to two lines of text to avoid interface overwhelming but will show the context"
        let subtitle = "News Category"
        let section = "default"
        let settings = OWArticleSettings(section: section,
                                         starRatingEnabled: true)

        return OWArticle(
            articleInformationStrategy:
                    .local(data:
                            OWArticleExtraData(
                                url: URL(string: url)!,
                                title: title,
                                subtitle: subtitle,
                                thumbnailUrl: URL(string: imageUrl)!)
                          ),
            additionalSettings: settings)
    }
}
