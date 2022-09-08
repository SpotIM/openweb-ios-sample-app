//
//  OWAdditionalConfiguration.swift
//  SpotImCore
//
//  Created by Alon Haiut on 20/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWAdditionalConfiguration {
    case suppressFinmbFilter
}
#else
enum OWAdditionalConfiguration {
    case suppressFinmbFilter
}

#endif
