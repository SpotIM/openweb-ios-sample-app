//
//  OWCommentCreationStyle+Analytics.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 19/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

extension OWCommentCreationStyle {
    var analyticsPayload: OWAnalyticEventPayload {
        switch self {
        case .regular:
            return OWAnalyticEventPayload(payloadDictionary: ["style": "regular"])
        case .light:
            return OWAnalyticEventPayload(payloadDictionary: ["style": "light"])
        case .floatingKeyboard(let accessoryViewStrategy):
            return OWAnalyticEventPayload(payloadDictionary: ["style": "floatingKeyboard", "accessoryViewStrategy": accessoryViewStrategy])
        }
    }
}
