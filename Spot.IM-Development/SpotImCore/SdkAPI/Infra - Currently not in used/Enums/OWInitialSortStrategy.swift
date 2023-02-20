//
//  OWInitialSortStrategy.swift
//  SpotImCore
//
//  Created by Alon Haiut on 12/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWInitialSortStrategy {
    case useServerConfig
    case use(sortOption: OWSortOption)
}
#else
enum OWInitialSortStrategy {
    case useServerConfig
    case use(sortOption: OWSortOption)
}
#endif
