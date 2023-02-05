//
//  SpotImReadOnlyMode+Extensions.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 15/03/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import SpotImCore

extension SpotImReadOnlyMode {
    static func parseSampleAppManualConfig() -> SpotImReadOnlyMode {
        let readOnlyModeRawValue = UserDefaultsProvider.shared.get(key: UserDefaultsProvider.UDKey<Int>.isReadOnlyEnabled, defaultValue: 0)
        let readOnlyMode: SpotImReadOnlyMode
        switch readOnlyModeRawValue {
        case 1:
            readOnlyMode = .enable
            break
        case 2:
            readOnlyMode = .disable
            break
        default:
            readOnlyMode = .default
        }

        return readOnlyMode
    }
}
