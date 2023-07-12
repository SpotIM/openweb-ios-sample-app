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
    let timestamp: TimeInterval
    let articleUrl: String
    let layoutStyle: OWLayoutStyle
    let component: OWAnalyticsComponent

    // calculated property to OWAnalyticEventServer
    func analyticEventServer() -> OWAnalyticEventServer {
        let generalData = OWAnalyticEventServerGeneralData(
            articleUrl: articleUrl,
            userStatus: "", // TODO: should we get it or set it here?
            userId: "", // TODO: should we get it or set it here?
            guid: "", // TODO: should we get it or set it here?
            layoutStyle: layoutStyle.rawValue
        )

        return OWAnalyticEventServer(
            eventName: type.eventName,
            eventGroup: type.eventGroup.rawValue,
            eventTimestamp: timestamp,
            componentName: component.rawValue,
            generalData: generalData
        )
    }
}

enum OWAnalyticsComponent: String {
    case conversation = "full_conversation"
    case preConversation = "pre_conversation"
    case commentThread = "comment_thread"
    case commentCreation = "comment_creation"
}
