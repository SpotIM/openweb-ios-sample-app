//
//  OWAnalyticSourceType.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 15/08/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

enum OWAnalyticSourceType {
    case preConversation
    case conversation
    case commentCreation
    case commentThread
    case reportReason
    case clarityDetails
    case commenterAppeal
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
        case .clarityDetails:
            return "clarity_details"
        case .commenterAppeal:
            return "commenter_appeal"
        case .none:
            return "none"
        }
    }
}
