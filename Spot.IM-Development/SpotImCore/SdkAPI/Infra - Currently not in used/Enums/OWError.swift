//
//  OWError.swift
//  SpotImCore
//
//  Created by Alon Haiut on 05/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API

public enum OWError: Error, Codable {
    case reportReasonSubmitError(title: String, description: String)
    case missingSpotId
    case missingPostId
    case castingError(description: String)
    case preConversationFlow
    case conversationFlow
    case commentCreationFlow
    case reportReasonFlow
    case commentThreadFlow
    case preConversationView
    case conversationView
    case commentCreationView
    case commentThreadView
    case reportReasonView
    case clarityDetailsView
    case webTabView
    case logout
    case userStatus
    case ssoStart
    case ssoComplete
    case ssoProvider
    case alreadyLoggedIn
    case conversationCounters
    // TODO: Will be removed once the API is no longer beta and be official
    case missingImplementation

    public var description: String {
        switch self {
        case .reportReasonSubmitError:
            return "Error - submitting report reason failed"
        case .missingSpotId:
            return "Error - spotId must be set first under `OpenWeb.manager`"
        case .missingPostId:
            return "Error - postId must be set first via any of the APIs calls"
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
        case .reportReasonView:
            return "Error in the process of starting report reason as a view"
        case .clarityDetailsView:
            return "Error in the process of starting clarity details as a view"
        case .webTabView:
            return "Error in the process of starting web tab as a view"
        case .logout:
            return "Error in the process of logout"
        case .userStatus:
            return "Error in the process of getting userStatus"
        case .ssoStart:
            return "Error in the process of SSO start"
        case .ssoComplete:
            return "Error in the process of SSO complete"
        case .ssoProvider:
            return "Error in the process of SSO with third party provider"
        case .alreadyLoggedIn:
            return "Error - a user is already logged in"
        case .missingImplementation:
            return "Error - Not implemented yet."
        case .reportReasonFlow:
            return "Error - In the process of starting report reason flow"
        case .conversationCounters:
            return "Error - In getting conversation counters"
        }
    }
}

#else

enum OWError: Error, Codable {
    case reportReasonSubmitError(title: String, description: String)
    case missingSpotId
    case missingPostId
    case castingError(description: String)
    case preConversationFlow
    case conversationFlow
    case commentCreationFlow
    case reportReasonFlow
    case commentThreadFlow
    case preConversationView
    case conversationView
    case commentCreationView
    case commentThreadView
    case reportReasonView
    case clarityDetailsView
    case webTabView
    case logout
    case userStatus
    case ssoStart
    case ssoComplete
    case alreadyLoggedIn
    case conversationCounters
    // TODO: Will be removed once the API is no longer beta and be official
    case missingImplementation

    var description: String {
        switch self {
        case .reportReasonSubmitError:
            return "Error - submitting report reason failed"
        case .missingSpotId:
            return "Error - spotId must be set first under `OpenWeb.manager`"
        case .missingPostId:
            return "Error - postId must be set first via any of the APIs calls"
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
        case .reportReasonView:
            return "Error in the process of starting report reason as a view"
        case .clarityDetailsView:
            return "Error in the process of starting clarity details as a view"
        case .webTabView:
            return "Error in the process of starting web tab as a view"
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
        case .reportReasonFlow:
            return "Error - In the process of starting report reason flow"
        case .conversationCounters:
            return "Error - In getting conversation counters"
        }
    }
}

#endif
