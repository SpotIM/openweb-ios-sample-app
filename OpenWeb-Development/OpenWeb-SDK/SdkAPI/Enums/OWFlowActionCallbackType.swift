//
//  OWFlowActionCallbackType.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 09/09/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation

public enum OWFlowActionCallbackType: Codable {
    case openPublisherProfile(ssoPublisherId: String, type: OWUserProfileType, presentationalMode: OWPresentationalMode)
    case conversationDismissed
}

extension OWFlowActionCallbackType: Equatable {
    public static func == (lhs: OWFlowActionCallbackType, rhs: OWFlowActionCallbackType) -> Bool {
        switch (lhs, rhs) {
        case (let .openPublisherProfile(lhsId, lhsType, lhsPresentationalMode), let .openPublisherProfile(rhsId, rhsType, rhsPresentationalMode)):
            return lhsId == rhsId && lhsType == rhsType && lhsPresentationalMode == rhsPresentationalMode
        case (.conversationDismissed, .conversationDismissed):
            return true
        default:
            return false
        }
    }
}

