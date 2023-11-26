//
//  OWOrientation.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 16/10/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWOrientation: Codable {
    case portrait
    case landscape
}
#else
enum OWOrientation: Codable {
    case portrait
    case landscape
}
#endif
