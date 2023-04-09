//
//  OWError.swift
//  SpotImCore
//
//  Created by Alon Haiut on 05/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWError: Error {
    case missingSpotId
    case castingError(description: String)
    case preConversationFlow
    case conversationFlow
    case commentCreationFlow
    case commentThreadFlow
    case preConversationView
    case conversationView
    case commentCreationView
    case commentThreadView
    case logout
    case userStatus
    case ssoStart
    case ssoComplete
    case alreadyLoggedIn
    // TODO: Will be removed once the API is no longer beta and be official
    case missingImplementation

    public var description: String {
        switch self {
        case .missingSpotId:
            return "Error - spotId must be set first under `OpenWeb.manager`"
        case .castingError(let des):
            return des
        case .preConversationFlow:
            return "Error in the process of starting pre conversation flow"
        case .conversationFlow:
            return "Error in the process of starting conversation flow"
        case .commentCreationFlow:
            return "Error in the process of starting comment creation flow"
        case .commentThreadFlow:
            return "Error in the process of starting comment thread flow"
        case .preConversationView:
            return "Error in the process of starting pre conversation as a view"
        case .conversationView:
            return "Error in the process of starting conversation as a view"
        case .commentCreationView:
            return "Error in the process of starting comment creation as a view"
        case .commentThreadView:
            return "Error in the process of starting comment thread as a view"
        case .logout:
            return "Error in the process of logout"
        case .userStatus:
            return "Error in the process of getting userStatus"
        case .ssoStart:
            return "Error in the process of SSO start"
        case .ssoComplete:
            return "Error in the process of SSO complete"
        case .alreadyLoggedIn:
            return "Error - a user is already logged in"
        case .missingImplementation:
            return "Error - Not implemented yet."
        }
    }
}
#else
enum OWError: Error {
    case missingSpotId
    case castingError(description: String)
    case preConversationFlow
    case conversationFlow
    case commentCreationFlow
    case commentThreadFlow
    case preConversationView
    case conversationView
    case commentCreationView
    case commentThreadView
    case logout
    case userStatus
    case ssoStart
    case ssoComplete
    case alreadyLoggedIn
    // TODO: Will be removed once the API is no longer beta and be official
    case missingImplementation

    var description: String {
        switch self {
        case .missingSpotId:
            return "Error - spotId must be set first under `OpenWeb.manager`"
        case .castingError(let des):
            return des
        case .preConversationFlow:
            return "Error in the process of starting pre conversation flow"
        case .conversationFlow:
            return "Error in the process of starting conversation flow"
        case .commentCreationFlow:
            return "Error in the process of starting comment creation flow"
        case .commentThreadFlow:
            return "Error in the process of starting comment thread flow"
        case .preConversationView:
            return "Error in the process of starting pre conversation as a view"
        case .conversationView:
            return "Error in the process of starting conversation as a view"
        case .commentCreationView:
            return "Error in the process of starting comment creation as a view"
        case .commentThreadView:
            return "Error in the process of starting comment thread as a view"
        case .logout:
            return "Error in the process of logout"
        case .userStatus:
            return "Error in the process of getting userStatus"
        case .ssoStart:
            return "Error in the process of SSO start"
        case .ssoComplete:
            return "Error in the process of SSO complete"
        case .alreadyLoggedIn:
            return "Error - a user is already logged in"
        case .missingImplementation:
            return "Error - Not implemented yet."
        }
    }
}
#endif
