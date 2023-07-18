//
//  OWViewSourceType+Extensions.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 18/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

extension OWViewSourceType {
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
        }
    }
}
