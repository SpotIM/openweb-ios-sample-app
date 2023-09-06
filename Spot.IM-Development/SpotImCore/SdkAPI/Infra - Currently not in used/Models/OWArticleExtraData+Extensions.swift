//
//  OWArticleExtraData+Extensions.swift
//  Spot-IM.Development
//
//  Created by  Nogah Melamed on 04/09/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public extension OWArticleExtraData {
    static let empty: OWArticleExtraData = OWArticleExtraData(
        url: URL(fileURLWithPath: ""),
        title: "",
        subtitle: nil,
        thumbnailUrl: nil)
}

#else
extension OWArticleExtraData {
    static let empty: OWArticleExtraData = OWArticleExtraData(
        url: URL(fileURLWithPath: ""),
        title: "",
        subtitle: nil,
        thumbnailUrl: nil)
}
#endif
