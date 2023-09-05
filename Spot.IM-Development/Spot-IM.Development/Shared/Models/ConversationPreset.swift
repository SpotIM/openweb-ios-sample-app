//
//  ConversationPreset.swift
//  Spot-IM.Development
//
//  Created by Revital Pisman on 11/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

struct ConversationPreset {
    let displayName: String
    let conversationDataModel: SDKConversationDataModel
    let section: String?
}

// swiftlint:disable line_length
extension ConversationPreset {
    static let mockModels = Self.createMockModels()

    static func demoSpot() -> ConversationPreset {
        return ConversationPreset(displayName: "Demo Spot",
                                  conversationDataModel: SDKConversationDataModel(spotId: "sp_eCIlROSD",
                                                                                  postId: "sdk1"),
                                  section: nil)
    }

    static func createMockModels() -> [ConversationPreset] {

        let demoConversationPreset = [demoSpot()]

    #if PUBLIC_DEMO_APP
        return demoConversationPreset

    #else
        return demoConversationPreset + [ConversationPreset(displayName: "FOX News",
                                                            conversationDataModel: SDKConversationDataModel(spotId: "sp_ANQXRpqH",
                                                                                                            postId: "urn:uri:base64:3cb1232f-b7ea-5546-81a5-395a75a27b1b"),
                                                            section: nil),
                                         ConversationPreset(displayName: "Yahoo",
                                                            conversationDataModel: SDKConversationDataModel(spotId: "sp_Rba9aFpG",
                                                                                                            postId: "finmb$24937"),
                                                            section: "stock"),
                                         ConversationPreset(displayName: "Ynet",
                                                            conversationDataModel: SDKConversationDataModel(spotId: "sp_AJXaDckj",
                                                                                                            postId: "S19Z20aTU"),
                                                            section: nil),
                                         ConversationPreset(displayName: "DailyMotion - Staging",
                                                            conversationDataModel: SDKConversationDataModel(spotId: "sp_srsgdH9A",
                                                                                                            postId: "x8ick9b"),
                                                            section: nil),
                                         ConversationPreset(displayName: "DailyMotion - beta",
                                                            conversationDataModel: SDKConversationDataModel(spotId: "sp_ToLXXNEQ",
                                                                                                            postId: "x8cpf62"),
                                                            section: nil),
                                         ConversationPreset(displayName: "DailyMotion - Prod",
                                                            conversationDataModel: SDKConversationDataModel(spotId: "sp_ybZYQUfH",
                                                                                                            postId: "x8jj55n"),
                                                            section: nil),
                                         ConversationPreset(displayName: "mobile SSO",
                                                            conversationDataModel: SDKConversationDataModel(spotId: "sp_mobileSSO",
                                                                                                            postId: "sdk1"),
                                                            section: nil),
                                         ConversationPreset(displayName: "mobile Guest",
                                                            conversationDataModel: SDKConversationDataModel(spotId: "sp_mobileGuest",
                                                                                                            postId: "sdk1"),
                                                            section: "other_section"),
                                         ConversationPreset(displayName: "mobile Social",
                                                            conversationDataModel: SDKConversationDataModel(spotId: "sp_mobileSocial",
                                                                                                            postId: "sdk1"),
                                                            section: nil),
                                         ConversationPreset(displayName: "mobile Social Guest",
                                                            conversationDataModel: SDKConversationDataModel(spotId: "sp_mobileSocialGuest",
                                                                                                            postId: "sdk1"),
                                                            section: nil)]

    #endif
    }
}
// swiftlint:enable line_length
