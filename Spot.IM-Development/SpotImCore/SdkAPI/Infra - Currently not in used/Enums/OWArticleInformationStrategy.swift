//
//  OWArticleInformationStrategy.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 23/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWArticleInformationStrategy: Codable {
    case server
    case local(data: OWArticleExtraData)
}
#else
enum OWArticleInformationStrategy: Codable {
    case server
    case local(data: OWArticleExtraData)
}
#endif

