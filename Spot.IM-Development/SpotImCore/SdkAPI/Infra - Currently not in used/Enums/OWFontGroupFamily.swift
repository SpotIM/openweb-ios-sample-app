//
//  OWFontGroupFamily.swift
//  SpotImCore
//
//  Created by Alon Haiut on 19/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWFontGroupFamily: Codable {
    case `default`
    case custom(fontFamily: String)
}

#else
enum OWFontGroupFamily: Codable {
    case `default`
    case custom(fontFamily: String)
}
#endif
