//
//  OWAnalyticSourceType.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 15/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

enum OWAnalyticSourceType {
    case preConversation
    case conversation
    case commentCreation
    case commentThread
    case reportReason
    case none

    var analyticsComponentName: String {
        switch(self) {
        case .commentCreation:
            return "comment_creation"
        case .preConversation:
            return "pre_conversation"
        case .conversation:
            return "full_conversation"
        case .commentThread:
            return "comment_thread"
        case .reportReason:
            return "report_reason"
        case .none:
            return "none"
        }
    }
}
