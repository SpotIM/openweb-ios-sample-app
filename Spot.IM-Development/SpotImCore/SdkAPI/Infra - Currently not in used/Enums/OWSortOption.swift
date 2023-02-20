//
//  OWSortOption.swift
//  SpotImCore
//
//  Created by Alon Haiut on 08/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWSortOption: String {
    case best
    case newest
    case oldest
}
#else
enum OWSortOption: String {
    case best
    case newest
    case oldest
}
#endif
