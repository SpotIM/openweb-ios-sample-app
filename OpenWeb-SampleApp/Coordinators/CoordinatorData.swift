//
//  CoordinatorData.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 11/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import OpenWebSDK

enum CoordinatorData {
    case conversationDataModel(data: SDKConversationDataModel)
    case actionsFlowSettings(data: SDKUIFlowActionSettings)
    case actionsFlowPartialScreenSettings(data: SDKUIFlowPartialScreenActionSettings)
    case actionsViewSettings(data: SDKUIIndependentViewsActionSettings)
    case postId(data: OWPostId)
    case settingsScreen(data: [SettingsGroupType])
}
