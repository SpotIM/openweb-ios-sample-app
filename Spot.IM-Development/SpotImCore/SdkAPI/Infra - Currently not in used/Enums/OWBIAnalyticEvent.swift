//
//  OWBIAnalyticEvent.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 14/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

// TODO: init with eventType
#if NEW_API
public enum OWBIAnalyticEvent {
    case a
}

#else
enum OWBIAnalyticEvent {
    case a
}
#endif
