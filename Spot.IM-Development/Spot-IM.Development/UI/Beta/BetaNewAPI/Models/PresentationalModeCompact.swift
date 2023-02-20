//
//  PresentationalModeCompact.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 04/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import SpotImCore

#if NEW_API
enum PresentationalModeCompact {
    case present(style: OWModalPresentationStyle)
    case push
}
#else
enum PresentationalModeCompact {
    case present
    case push
}
#endif
