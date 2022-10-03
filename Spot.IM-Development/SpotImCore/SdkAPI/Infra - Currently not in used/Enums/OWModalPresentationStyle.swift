//
//  OWModalPresentationStyle.swift
//  SpotImCore
//
//  Created by Alon Haiut on 11/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWModalPresentationStyle {
    case fullScreen
    case pageSheet
}
#else
enum OWModalPresentationStyle {
    case fullScreen
    case pageSheet
}
#endif
