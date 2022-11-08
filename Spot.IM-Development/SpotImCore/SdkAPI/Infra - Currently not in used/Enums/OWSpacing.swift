//
//  OWSpacing.swift
//  SpotImCore
//
//  Created by Alon Haiut on 08/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWSpacing {
    case regular
    case large
    case compact
    case custom(belowHeader: CGFloat, betweenComments: CGFloat)
}
#else
enum OWSpacing {
    case regular
    case large
    case compact
    case custom(belowHeader: CGFloat, betweenComments: CGFloat)
}
#endif
