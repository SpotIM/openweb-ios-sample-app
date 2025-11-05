//
//  SDKUIFlowPartialScreenActionType.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Shprung on 22/10/2025.
//

import Foundation

enum SDKUIFlowPartialScreenActionType {
    case fullConversation
    case commentCreation
    case commentThread
    case notifications
    case profile(userId: String)
    case clarityDetails
    case reportReason
}
