//
//  OWOrientationEnforcement.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 16/10/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWOrientationEnforcement: Codable {
    case enableAll
    case enable(orientations: [OWOrientation])
}
#else
enum OWOrientationEnforcement: Codable {
    case enableAll
    case enable(orientations: [OWOrientation])
}
#endif
