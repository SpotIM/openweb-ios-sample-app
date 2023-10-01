//
//  OWClarityDetailsType.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 22/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWClarityDetailsType: Codable {
    case rejected
    case pending
}
#else
enum OWClarityDetailsType: Codable {
    case rejected
    case pending
}
#endif
