//
//  OWCommentCreationSettings.swift
//  SpotImCore
//
//  Created by Alon Haiut on 08/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public struct OWCommentCreationSettings: OWCommentCreationSettingsProtocol {
    public let conversationSettings: OWConversationSettingsProtocol
    
    public init(conversationSettings: OWConversationSettingsProtocol) {
        self.conversationSettings = conversationSettings
    }
}
#else
struct OWCommentCreationSettings: OWCommentCreationSettingsProtocol {
    let conversationSettings: OWConversationSettingsProtocol
}
#endif
