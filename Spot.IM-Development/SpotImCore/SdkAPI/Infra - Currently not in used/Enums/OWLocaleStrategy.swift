//
//  OWLocaleStrategy.swift
//  SpotImCore
//
//  Created by Alon Haiut on 26/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWLocaleStrategy {
    case useDevice
    case useServerConfig // Will be default "en-US" in case locale can't be generated from server config
    case use(localeIdentifier: String) // Will be default to "en-US" in case locale can't be generated from the provided identifier
}
#else
enum OWLocaleStrategy {
    case useDevice
    case useServerConfig // Will be default "en-US" in case locale can't be generated from server config
    case use(localeIdentifier: String) // Will be default to "en-US" in case locale can't be generated from the provided identifier
}
#endif
