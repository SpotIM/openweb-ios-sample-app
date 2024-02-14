//
//  OWThemeStyleEnforcement+Analytics.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 15/08/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

extension OWThemeStyleEnforcement {
    var analyticsPayload: OWAnalyticEventPayload {
        switch self {
        case .none:
            return OWAnalyticEventPayload(payloadDictionary: [OWAnalyticEventPayloadKeys.theme: "none"])
        case .theme(let theme):
            return OWAnalyticEventPayload(payloadDictionary: [OWAnalyticEventPayloadKeys.style: theme.rawValue])
        }
    }
}
