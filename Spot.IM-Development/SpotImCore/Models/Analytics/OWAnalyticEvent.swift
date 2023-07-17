//
//  OWAnalyticEvent.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 12/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

struct OWAnalyticEvent: OWUpdaterProtocol {
    let type: OWAnalyticEventType
    let timestamp: String
    let articleUrl: String
    let layoutStyle: OWLayoutStyle
    let component: OWAnalyticsComponent
    let userStatus: String
    let userId: String
    let guid: String
}

extension OWAnalyticEvent {
    func analyticEventServer() -> OWAnalyticEventServer {
        let generalData = OWAnalyticEventServerGeneralData(
            articleUrl: articleUrl,
            userStatus: userStatus,
            userId: userId,
            guid: guid,
            layoutStyle: layoutStyle.rawValue
        )

        return OWAnalyticEventServer(
            eventName: type.eventName,
            eventGroup: type.eventGroup.rawValue,
            eventTimestamp: timestamp,
            componentName: component.rawValue,
            payload: type.payload,
            generalData: generalData
        )
    }
}
