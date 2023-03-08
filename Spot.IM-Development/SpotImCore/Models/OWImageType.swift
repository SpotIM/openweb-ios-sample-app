//
//  OWImageType.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 12/04/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
enum OWImageType {
    case defaultImage
    case custom(url: URL)
}

extension OWImageType: Equatable {
    static func == (lhs: OWImageType, rhs: OWImageType) -> Bool {
        switch (lhs, rhs) {
        case (.defaultImage, .defaultImage):
            return true
        case (.custom(let lUrl), .custom(let rUrl)):
            return lUrl.absoluteString == rUrl.absoluteString
        default:
            return false
        }
    }
}
