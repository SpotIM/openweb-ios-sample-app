//
//  OWSpacerStyle.swift
//  SpotImCore
//
//  Created by Revital Pisman on 13/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWSpacerStyle {
    case comment
    case community
    case none
}
#else
enum OWSpacerStyle {
    case comment
    case community
    case none
}
#endif

