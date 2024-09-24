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

extension OWFlowActionCallbackType: Equatable {}

