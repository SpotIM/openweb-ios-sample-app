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
    case castingError(description: String)
    case conversationFlow
    case preConversationFlow
    case commentCreationFlow
    public var description: String {
        switch self {
        case .castingError(let des):
            return des
        case .conversationFlow:
            return "Error in the process of starting conversation flow"
        case .preConversationFlow:
            return "Error in the process of starting pre conversation flow"
        case .commentCreationFlow:
            return "Error in the process of starting comment creation flow"
        }
    }
}
#else
enum OWError: Error {
    case castingError(description: String)
    case conversationFlow
    case preConversationFlow
    case commentCreationFlow
    var description: String {
        switch self {
        case .castingError(let des):
            return des
        case .conversationFlow:
            return "Error in the process of starting conversation flow"
        case .preConversationFlow:
            return "Error in the process of starting pre conversation flow"
        case .commentCreationFlow:
            return "Error in the process of starting comment creation flow"
        }
    }
}
#endif
