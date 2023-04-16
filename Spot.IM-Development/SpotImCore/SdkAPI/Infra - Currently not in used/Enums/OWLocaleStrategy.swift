//
//  OWLocaleStrategy.swift
//  SpotImCore
//
//  Created by Alon Haiut on 26/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWLocaleStrategy: Codable {
    case useDevice
    case useServerConfig // Will be default "en-US" in case locale can't be generated from server config
    case use(locale: Locale)
}
#else
enum OWLocaleStrategy: Codable {
    case useDevice
    case useServerConfig // Will be default "en-US" in case locale can't be generated from server config
    case use(locale: Locale)
}
#endif
