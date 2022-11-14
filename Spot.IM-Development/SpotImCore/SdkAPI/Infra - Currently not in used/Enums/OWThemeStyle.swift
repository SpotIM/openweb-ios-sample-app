//
//  OWThemeStyle.swift
//  SpotImCore
//
//  Created by Alon Haiut on 08/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWThemeStyle {
    case light
    case dark
}
#else
enum OWThemeStyle {
    case light
    case dark
}
#endif
