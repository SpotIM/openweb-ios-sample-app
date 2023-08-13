//
//  OWNavigationBarStyle.swift
//  SpotImCore
//
//  Created by Alon Haiut on 12/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWNavigationBarStyle {
    case regular
    case largeTitles // Default style
}

#else
enum OWNavigationBarStyle {
    case regular
    case largeTitles
}
#endif
