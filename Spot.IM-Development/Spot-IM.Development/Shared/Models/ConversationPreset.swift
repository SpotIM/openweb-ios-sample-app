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
}

extension ConversationPreset {
    static let mockModels = Self.createMockModels()
    
    static func createMockModels() -> [ConversationPreset] {
        
        let demoConversationPreset = [ConversationPreset(displayName: "Demo Spot",
                                                     conversationDataModel: SDKConversationDataModel(spotId: "sp_eCIlROSD",
                                                                                                     postId: "sdk1"))]
        
    #if PUBLIC_DEMO_APP
        return demoConversationPreset
        
    #else
        // swiftlint:disable line_length
        return demoConversationPreset + [ConversationPreset(displayName: "FOX News",
                                                         conversationDataModel: SDKConversationDataModel(spotId: "sp_ANQXRpqH",
                                                                                                         postId: "urn:uri:base64:3cb1232f-b7ea-5546-81a5-395a75a27b1b")),
                                      
                                      ConversationPreset(displayName: "Yahoo",
                                                            conversationDataModel: SDKConversationDataModel(spotId: "sp_Rba9aFpG",
                                                                                                            postId: "finmb$24937")),
                                      
                                      ConversationPreset(displayName: "Ynet",
                                                               conversationDataModel: SDKConversationDataModel(spotId: "sp_AJXaDckj",
                                                                                                               postId: "S19Z20aTU")),
                                         
                                      ConversationPreset(displayName: "mobile SSO",
                                                         conversationDataModel: SDKConversationDataModel(spotId: "sp_mobileSSO",
                                                                                                         postId: "sdk1")),
                                      
                                      ConversationPreset(displayName: "mobile Guest",
                                                         conversationDataModel: SDKConversationDataModel(spotId: "sp_mobileGuest",
                                                                                                         postId: "sdk1")),
                                      
                                      ConversationPreset(displayName: "mobile Social",
                                                         conversationDataModel: SDKConversationDataModel(spotId: "sp_mobileSocial",
                                                                                                         postId: "sdk1")),
                                      
                                      ConversationPreset(displayName: "mobile Social Guest",
                                                         conversationDataModel: SDKConversationDataModel(spotId: "sp_mobileSocialGuest",
                                                                                                         postId: "sdk1"))]
        
        // swiftlint:enable line_length
    #endif
    }
}
