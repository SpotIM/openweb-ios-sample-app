//
//  SettingsColorCustomizationStyle.swift
//  Spot-IM.Development
//
//  Created by  Nogah Melamed on 27/12/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

public enum SettingsColorCustomizationStyle: Int {
    case none
    case style1
    case custom

    static var defaultIndex: Int {
        return 0
    }
}
