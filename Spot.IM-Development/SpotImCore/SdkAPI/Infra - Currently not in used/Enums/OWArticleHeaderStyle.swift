//
//  OWArticleHeaderStyle.swift
//  SpotImCore
//
//  Created by Revital Pisman on 18/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWArticleHeaderStyle: Codable {
    case none
    case regular
}

#else
enum OWArticleHeaderStyle: Codable {
    case none
    case regular
}
#endif
