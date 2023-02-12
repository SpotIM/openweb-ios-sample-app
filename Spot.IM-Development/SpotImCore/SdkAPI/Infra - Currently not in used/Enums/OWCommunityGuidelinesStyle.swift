//
//  OWCommunityGuidelinesStyle.swift
//  SpotImCore
//
//  Created by Alon Haiut on 31/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWCommunityGuidelinesStyle {
    case none
    case regular
    case compact
}

#else
enum OWCommunityGuidelinesStyle {
    case none
    case regular
    case compact
}
#endif
