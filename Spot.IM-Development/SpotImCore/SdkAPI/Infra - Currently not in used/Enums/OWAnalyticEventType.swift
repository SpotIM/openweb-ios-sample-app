//
//  OWAnalyticEvent.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 12/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

enum OWAnalyticEventType {
    case eventNumberOne(someProperty: String)

    var eventName: String {
        switch self {
        case .eventNumberOne:
            return "event_number_one"
        }
    }
}
