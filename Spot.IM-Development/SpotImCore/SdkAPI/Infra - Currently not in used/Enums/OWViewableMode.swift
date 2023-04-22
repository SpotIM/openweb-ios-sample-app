//
//  OWViewableMode.swift
//  SpotImCore
//
//  Created by Revital Pisman on 20/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWViewableMode {
    case partOfFlow
    case independent
}

#else
enum OWViewableMode {
    case partOfFlow
    case independent
}
#endif
