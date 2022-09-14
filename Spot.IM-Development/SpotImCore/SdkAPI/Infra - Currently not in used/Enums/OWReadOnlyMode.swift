//
//  OWReadOnlyMode.swift
//  SpotImCore
//
//  Created by Alon Haiut on 05/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWReadOnlyMode {
    case `default`
    case enable
    case disable
}
#else
enum OWReadOnlyMode {
    case `default`
    case enable
    case disable
}
#endif
