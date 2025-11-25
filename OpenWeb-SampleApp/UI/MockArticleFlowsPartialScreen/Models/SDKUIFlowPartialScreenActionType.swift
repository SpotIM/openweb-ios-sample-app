//
//  SDKUIFlowPartialScreenActionType.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Shprung on 22/10/2025.
//

import Foundation
import OpenWebSDK

enum SDKUIFlowPartialScreenActionType {
    case preConversationToFullConversation(presentationalMode: PresentationalModeCompact)
    case fullConversation(route: OWConversationRoute)
}
