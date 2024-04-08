//
//  OWArticleExtraData+Extensions.swift
//  OpenWeb-Development
//
//  Created by  Nogah Melamed on 04/09/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

public extension OWArticleExtraData {
    static let empty: OWArticleExtraData = OWArticleExtraData(
        url: URL(fileURLWithPath: ""),
        title: "",
        subtitle: nil,
        thumbnailUrl: nil)
}
