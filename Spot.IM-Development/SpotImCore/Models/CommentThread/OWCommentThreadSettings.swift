//
//  OWCommentThreadSettings.swift
//  SpotImCore
//
//  Created by Alon Shprung on 28/05/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public struct OWCommentThreadSettings: OWCommentThreadSettingsProtocol {
    public let conversationSettings: OWConversationSettingsProtocol

    public init(conversationSettings: OWConversationSettingsProtocol) {
        self.conversationSettings = conversationSettings
    }
}
#else
struct OWCommentThreadSettings: OWCommentThreadSettingsProtocol {
    let conversationSettings: OWConversationSettingsProtocol

    init(conversationSettings: OWConversationSettingsProtocol) {
        self.conversationSettings = conversationSettings
    }
}
#endif
