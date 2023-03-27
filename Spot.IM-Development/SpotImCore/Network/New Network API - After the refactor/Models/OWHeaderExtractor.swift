//
//  OWHeaderExtractor.swift
//  SpotImCore
//
//  Created by Alon Haiut on 16/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

class OWHeaderExtractor {
    static let `default` = OWHeaderExtractor()

    func extract(headerType: OWHTTPHeaderType, from dictionary: [AnyHashable: Any]) -> String? {
        return dictionary[headerType.rawValue] as? String
    }
}
