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
        return demoConversationPreset + [ConversationPreset(displayName: "FOX News",
                                                         conversationDataModel: SDKConversationDataModel(spotId: "sp_ANQXRpqH",
                                                                                                         postId: "sdk1")),
                                      
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
        
    #endif
    }
}
