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

    func analyticEventServer() -> OWAnalyticEventServer {
        let generalData = OWAnalyticEventServerGeneralData(
            articleUrl: articleUrl,
            userStatus: userStatus, // TODO: should we get it or set it here?
            userId: userId, // TODO: should we get it or set it here?
            guid: guid, // TODO: should we get it or set it here?
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
