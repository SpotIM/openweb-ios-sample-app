//
//  SDKUIFlowActionType.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 04/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

enum SDKUIFlowActionType {
    case preConversation(presentationalMode: PresentationalModeCompact)
    case fullConversation(presentationalMode: PresentationalModeCompact)
    case commentCreation(presentationalMode: PresentationalModeCompact)
    case commentThread(presentationalMode: PresentationalModeCompact)
}
