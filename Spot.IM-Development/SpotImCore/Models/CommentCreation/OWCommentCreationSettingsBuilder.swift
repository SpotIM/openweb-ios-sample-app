//
//  OWCommentCreationSettingsBuilder.swift
//  SpotImCore
//
//  Created by Alon Haiut on 11/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public struct OWCommentCreationSettingsBuilder: OWCommentCreationSettingsProtocol {
    public var conversationSettings: OWConversationSettingsProtocol

    public init(conversationSettings: OWConversationSettingsProtocol) {
        self.conversationSettings = conversationSettings
    }

    @discardableResult public mutating func conversationSettings(settings: OWConversationSettingsProtocol) -> OWCommentCreationSettingsProtocol {
        self.conversationSettings = settings
        return self
    }
}
#endif
