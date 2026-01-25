//
//  DevelopmentSDKConversationDataModel+Extensions.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 15/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

#if !PUBLIC_DEMO_APP
import Foundation
import OpenWeb_SampleApp_Internal_Configs

extension DevelopmentSDKConversationDataModel {
    func toSDKConversationDataModel() -> SDKConversationDataModel {
        return SDKConversationDataModel(spotId: spotId,
                                        postId: postId)
    }
}

#endif
