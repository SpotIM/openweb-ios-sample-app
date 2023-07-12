//
//  OWAnalyticEvent.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 12/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

enum OWAnalyticEventType {
    case fullConversationLoaded(someProperty: String)

    var eventName: String {
        switch self {
        case .fullConversationLoaded:
            return "fullConversationLoaded"
        }
    }

    var eventGroup: OWAnalyticEventGroup {
        switch self {
        case .fullConversationLoaded:
            return .loaded
        }
    }
}

enum OWAnalyticEventGroup: String {
    case loaded = "loaded"
}
