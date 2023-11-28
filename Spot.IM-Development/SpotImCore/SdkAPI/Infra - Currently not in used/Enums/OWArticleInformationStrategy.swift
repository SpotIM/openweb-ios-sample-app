//
//  OWArticleInformationStrategy.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 23/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

public enum OWArticleInformationStrategy: Codable {
    case server
    case local(data: OWArticleExtraData)
}
