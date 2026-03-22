//
//  SDKUIFlowActionType.swift
//  OpenWeb-Development
//
//  Created by Alon Haiut on 04/09/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import OpenWebSDK

enum SDKUIFlowActionType {
    case preConversation(presentationalMode: PresentationalModeCompact)
    case fullConversation(presentationalMode: PresentationalModeCompact)
    case commentCreation(presentationalMode: PresentationalModeCompact, type: OWCommentCreationType)
    case commentThread(presentationalMode: PresentationalModeCompact)
}
