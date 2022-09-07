//
//  OWArticle+Stub.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 07/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import SpotImCore

#if NEW_API
extension OWArticle {
    static func stub() -> OWArticle {
        let url = "https://test.com"
        let title = "Test Article"
        let section = "Cool Section"
        let settings = OWArticleSettings(section: section)

        return OWArticle(url: URL(string: url)!,
                         title: title,
                         subtitle: nil,
                         thumbnailUrl: nil,
                         additionalSettings: settings)
    }
}
#endif
