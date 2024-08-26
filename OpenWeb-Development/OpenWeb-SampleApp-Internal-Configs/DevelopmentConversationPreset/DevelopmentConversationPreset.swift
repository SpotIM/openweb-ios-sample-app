//
//  DevelopmentConversationPreset.swift
//  OpenWeb-SampleApp-Internal-Configs
//
//  Created by Alon Haiut on 15/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation

public struct DevelopmentConversationPreset {
    public let displayName: String
    public let conversationDataModel: DevelopmentSDKConversationDataModel
    public var section: String? = nil
}

public extension DevelopmentConversationPreset {
    static func demoSpot() -> DevelopmentConversationPreset {
        return DevelopmentConversationPreset(displayName: "Demo Spot",
                                  conversationDataModel: DevelopmentSDKConversationDataModel(spotId: "sp_eCIlROSD",
                                                                                  postId: "sdk1"))
    }

    static func developmentPresets() -> [DevelopmentConversationPreset] {
        // swiftlint:disable line_length
        return [demoSpot()] + [DevelopmentConversationPreset(displayName: "Mail Online (MOL)",
                                                            conversationDataModel: DevelopmentSDKConversationDataModel(spotId: "sp_jhHPoiRK",
                                                                                                            postId: "13019781")),
                DevelopmentConversationPreset(displayName: "FOX News",
                                                                                             conversationDataModel: DevelopmentSDKConversationDataModel(spotId: "sp_ANQXRpqH",
                                                                                                                                             postId: "urn:uri:base64:3cb1232f-b7ea-5546-81a5-395a75a27b1b")),
                DevelopmentConversationPreset(displayName: "Yahoo",
                                                            conversationDataModel: DevelopmentSDKConversationDataModel(spotId: "sp_Rba9aFpG",
                                                                                                            postId: "finmb$24937"),
                                                            section: "stock"),
                DevelopmentConversationPreset(displayName: "Ynet",
                                                            conversationDataModel: DevelopmentSDKConversationDataModel(spotId: "sp_AJXaDckj",
                                                                                                            postId: "S19Z20aTU")),
                DevelopmentConversationPreset(displayName: "DailyMotion - Staging",
                                                            conversationDataModel: DevelopmentSDKConversationDataModel(spotId: "sp_srsgdH9A",
                                                                                                            postId: "x8ick9b")),
                DevelopmentConversationPreset(displayName: "DailyMotion - beta",
                                                            conversationDataModel: DevelopmentSDKConversationDataModel(spotId: "sp_ToLXXNEQ",
                                                                                                            postId: "x8cpf62")),
                DevelopmentConversationPreset(displayName: "DailyMotion - Prod",
                                                            conversationDataModel: DevelopmentSDKConversationDataModel(spotId: "sp_ybZYQUfH",
                                                                                                            postId: "x8jj55n")),
                DevelopmentConversationPreset(displayName: "mobile SSO",
                                                            conversationDataModel: DevelopmentSDKConversationDataModel(spotId: "sp_mobileSSO",
                                                                                                            postId: "sdk1")),
                DevelopmentConversationPreset(displayName: "mobile Guest",
                                                            conversationDataModel: DevelopmentSDKConversationDataModel(spotId: "sp_mobileGuest",
                                                                                                            postId: "sdk1"),
                                                            section: "other_section"),
                DevelopmentConversationPreset(displayName: "mobile Social",
                                                            conversationDataModel: DevelopmentSDKConversationDataModel(spotId: "sp_mobileSocial",
                                                                                                            postId: "sdk1")),
                DevelopmentConversationPreset(displayName: "mobile Social Guest",
                                                            conversationDataModel: DevelopmentSDKConversationDataModel(spotId: "sp_mobileSocialGuest",
                                                                                                            postId: "sdk1"))]
    }
    // swiftlint:enable line_length
}
